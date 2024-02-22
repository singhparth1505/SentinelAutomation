#---------------------------------------terraform code for OOB use cases--------------------

data "azurerm_sentinel_alert_rule_template" "template_aad" {
    for_each = toset(var.azure_sentinel_rule_template_scheduled_AAD_displaynames)
    log_analytics_workspace_id = azurerm_log_analytics_workspace.LAWref.id
    display_name = each.key
    depends_on = [
      azurerm_log_analytics_solution.LAWsolref
    ]
}

resource "azurerm_sentinel_alert_rule_scheduled" "rules_aad013" {
  for_each = toset(var.azure_sentinel_rule_template_scheduled_AAD_displaynames)
  #name                       = element(split("/", data.azurerm_sentinel_alert_rule_template.template_aad[each.key].id), length(split("/", data.azurerm_sentinel_alert_rule_template.template_aad[each.key].id))-1)
  name                       = each.key
  log_analytics_workspace_id = azurerm_log_analytics_workspace.LAWref.id
  #alert_rule_template_guid = element(split("/", data.azurerm_sentinel_alert_rule_template.template_aad[each.key].id), length(split("/", data.azurerm_sentinel_alert_rule_template.template_aad[each.key].id))-1)
  display_name               = each.key
  description                = data.azurerm_sentinel_alert_rule_template.template_aad[each.key].scheduled_template.0.description
  severity                   = data.azurerm_sentinel_alert_rule_template.template_aad[each.key].scheduled_template.0.severity
  query                      = data.azurerm_sentinel_alert_rule_template.template_aad[each.key].scheduled_template.0.query
  query_frequency            = data.azurerm_sentinel_alert_rule_template.template_aad[each.key].scheduled_template.0.query_frequency
  query_period               = data.azurerm_sentinel_alert_rule_template.template_aad[each.key].scheduled_template.0.query_period
  tactics                    = data.azurerm_sentinel_alert_rule_template.template_aad[each.key].scheduled_template.0.tactics
  trigger_operator           = data.azurerm_sentinel_alert_rule_template.template_aad[each.key].scheduled_template.0.trigger_operator
  trigger_threshold          = data.azurerm_sentinel_alert_rule_template.template_aad[each.key].scheduled_template.0.trigger_threshold

  depends_on = [
  azurerm_log_analytics_solution.LAWsolref,azurerm_sentinel_alert_rule_scheduled.rule013,
  data.azurerm_sentinel_alert_rule_template.template_aad
]
}


#------TERRAFORM CODE for CUSTOM use cases QUERY RULE -------------------
resource "azurerm_sentinel_alert_rule_scheduled" "rule011" {
  name                       = "NSG use case"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.LAWref.id
  display_name               = "Activities performed in NSG"
  description = "Checks for every operation performed in NSG"
  severity                   = "Low"
  query_frequency = "PT15M"
  query_period = "PT1H"
  #query_period must larger than or equal to query_frequency, which ensures there is no gaps in the overall query coverage.
  query                      = <<QUERY
AzureDiagnostics | where Category == "NetworkSecurityGroupEvent"
| sort by TimeGenerated
QUERY

depends_on = [
  azurerm_log_analytics_solution.LAWsolref,null_resource.readcontentFile012
]
}


resource "azurerm_sentinel_alert_rule_scheduled" "rule013" {
  name                       = "Security Event log cleared"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.LAWref.id
  display_name               = "Security Event log cleared"
  description = "Checks for event id 1102 which indicates the security event log was cleared.It uses Event Source Name Microsoft-Windows-Eventlog to avoid generating false positives from other sources, like AD FS servers for instance."
  severity                   = "High"
  query_frequency = "PT15M"
  query_period = "PT1H"
  #query_period must larger than or equal to query_frequency, which ensures there is no gaps in the overall query coverage.
  query                      = <<QUERY
(union isfuzzy=true
(
SecurityEvent
| where EventID == 1102 and EventSourceName == "Microsoft-Windows-Eventlog"
| summarize StartTimeUtc = min(TimeGenerated), EndTimeUtc = max(TimeGenerated), EventCount = count() by Computer, Account, EventID, Activity
| extend timestamp = StartTimeUtc, AccountCustomEntity = Account, HostCustomEntity = Computer
),
(
WindowsEvent
| where EventID == 1102 and Provider == "Microsoft-Windows-Eventlog"
| extend Account =  strcat(tostring(EventData.SubjectDomainName),"\\", tostring(EventData.SubjectUserName))
| extend Activity= "1102 - The audit log was cleared."
| summarize StartTimeUtc = min(TimeGenerated), EndTimeUtc = max(TimeGenerated), EventCount = count() by Computer, Account, EventID, Activity
| extend timestamp = StartTimeUtc, AccountCustomEntity = Account, HostCustomEntity = Computer
)
)
QUERY

depends_on = [
  azurerm_log_analytics_solution.LAWsolref,null_resource.readcontentFile012
]
}

resource "azurerm_sentinel_alert_rule_scheduled" "rule020" {
  name                       = "Activities performed in key vault"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.LAWref.id
  display_name               = "Activities performed in key vault"
  description = "Checks for every operation performed in key vault"
  severity                   = "Low"
  query_frequency = "PT15M"
  query_period = "PT1H"
  #query_period must larger than or equal to query_frequency, which ensures there is no gaps in the overall query coverage.
  query                      = <<QUERY
 let Now = now();
(range TimeGenerated from ago(7d) to Now - 1d step 1d
| extend Count = 0
| union isfuzzy=true
    (AzureDiagnostics
    | where ResourceProvider == "MICROSOFT.KEYVAULT"
    | summarize Count = count() by bin_at(TimeGenerated, 1d, Now))
| summarize Count=max(Count) by bin_at(TimeGenerated, 1d, Now)
| sort by TimeGenerated
| project
    Value = iff(isnull(Count), 0, Count),
    Time = TimeGenerated,
    Legend = "AzureDiagnostics")
| render timechart 
QUERY

depends_on = [
  azurerm_log_analytics_solution.LAWsolref,null_resource.readcontentFile012
]
}
#-------------powershell file to deploy use cases------------
resource "null_resource" "readcontentFile012" {
  provisioner "local-exec" {
    command     = "./Final-UC-Deployment.ps1"
    interpreter = ["PowerShell", "-Command"]
  }
  depends_on = [
    azurerm_log_analytics_solution.LAWsolref,null_resource.linux_syslog10
  ]
}

#------------------------------------------