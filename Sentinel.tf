#-------resource group------------
resource "azurerm_resource_group" "RGref" {
  name     = var.rg_name
  location = var.location
}
#------------Log analytics workspace------------
resource "azurerm_log_analytics_workspace" "LAWref" {
  name                = var.LAWname
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  depends_on = [
    azurerm_resource_group.RGref
  ]
}
#----------Log analytics solution which will create Sentinel------
resource "azurerm_log_analytics_solution" "LAWsolref" {
  solution_name         = "SecurityInsights"
  location              = var.location
  resource_group_name   = var.rg_name
  workspace_resource_id = azurerm_log_analytics_workspace.LAWref.id
  workspace_name        = azurerm_log_analytics_workspace.LAWref.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityInsights"
  }
  depends_on = [
    azurerm_log_analytics_workspace.LAWref
  ]
}
#----------------NSG-------------
resource "azurerm_network_security_group" "NSGref" {
  name                = "SentinelSecurityGroup1"
  location            = azurerm_resource_group.RGref.location
  resource_group_name = azurerm_resource_group.RGref.name

  security_rule {
    name                       = "RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefixes      = ["${chomp(data.http.myip.response_body)}/32"]
    destination_address_prefix = "*"
  }
depends_on = [
  data.http.myip,azurerm_log_analytics_solution.LAWsolref
]
}

#-----------IP address of executioner------------

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
  depends_on = [
    azurerm_log_analytics_workspace.LAWref
  ]
}
#-------------------------keyVault-----------
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "KeyVaultref" {
  name                        = "SentinelKVdev01"
  location                    = azurerm_resource_group.RGref.location
  resource_group_name         = azurerm_resource_group.RGref.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  public_network_access_enabled = true
  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get","List","Create","Delete"
    ]

    secret_permissions = [
      "Get","List","Set","Delete"
    ]

    storage_permissions = [
      "Get","List","Set","Delete"
    ]
  }
  network_acls {
    bypass = "AzureServices"
    default_action = "Deny"
    ip_rules = ["${chomp(data.http.myip.response_body)}/32"]
  }
  depends_on = [
    azurerm_network_security_group.NSGref
  ]
}
#---------------data source windows event----------------
resource "azurerm_log_analytics_datasource_windows_event" "example01" {
  count = 13
  name = var.example-lad-wpc[count.index]
  resource_group_name = azurerm_resource_group.RGref.name
  workspace_name = azurerm_log_analytics_workspace.LAWref.name
  event_log_name = var.event_log_name[count.index]
  # event_types = ["error", "warning", "information"]
event_types = ["Error", "Warning", "Information"]
  depends_on = [
    azurerm_log_analytics_solution.LAWsolref
  ]
}



#-------------powershell file to deploy playbook------------
resource "null_resource" "jsonplaybook" {
  provisioner "local-exec" {
    command     = "./jsonplaybook.ps1"
    interpreter = ["PowerShell", "-Command"]
  }
  depends_on = [
    azurerm_log_analytics_solution.LAWsolref,
    null_resource.readcontentFile012
  ]
}

#-----------syslog data source------------
resource "null_resource" "linux_syslog10" {
  provisioner "local-exec" {
     command = "./linux_syslog.ps1"
     interpreter = ["PowerShell", "-Command"]
    }
     depends_on =[
       azurerm_log_analytics_datasource_windows_event.example01,
       ]
    }

     #In case of digitally signed error just run this command:
    #Unblock-File -Path .\linux_syslog.ps1

   
# data "azurerm_network_security_group" "nsg1" {
#   name                = "SentinelVM-nsg"
#   resource_group_name = azurerm_resource_group.RGref.name
# }
#------------Diagnostic setting for NSG Data connector--------------
resource "azurerm_monitor_diagnostic_setting" "example" {
  name               = "NSGdiagSettings"
  target_resource_id = azurerm_network_security_group.NSGref.id
 log_analytics_workspace_id = azurerm_log_analytics_workspace.LAWref.id

  
  dynamic "log" {
for_each = var.nsg_log_category
content {
  category = log.value
  enabled  = true
}
}
  depends_on = [
    azurerm_network_security_group.NSGref
  ]
}
# data "azurerm_key_vault" "kvref1" {
#   name                = "SentinelKV2020"
#   resource_group_name = azurerm_resource_group.RGref.name
# }

#------------Diagnostic setting for KeyVault Data connector--------------
resource "azurerm_monitor_diagnostic_setting" "KVdiag" {
  name               = "KVdiagSettings"
  target_resource_id = azurerm_key_vault.KeyVaultref.id
 log_analytics_workspace_id = azurerm_log_analytics_workspace.LAWref.id

   dynamic "log" {
for_each = var.kv_log_category
content {
  category = log.value
  enabled  = true
}
}

  metric {
    category = "AllMetrics"
  }
 

  depends_on = [
    azurerm_monitor_diagnostic_setting.example,
    azurerm_key_vault.KeyVaultref
  ]
}

  output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.LAWref.id
}

  output "log_analytics_workspace_id1" {
  value = azurerm_log_analytics_workspace.LAWref.workspace_id
}

#------------Azure Active directory Data connector--------------
#  resource "azurerm_sentinel_data_connector_azure_active_directory" "DC_AAD" {
#   name                       = "AzureActiveDirectoryDC"
#   log_analytics_workspace_id = azurerm_log_analytics_solution.LAWsolref.workspace_resource_id
#   depends_on = [
#     azurerm_monitor_diagnostic_setting.KVdiag
#   ]
# }

#------------Office365 Data connector--------------
# resource "azurerm_sentinel_data_connector_office_365" "DC_office365" {
#   name                       = "Office365DC"
#   log_analytics_workspace_id = azurerm_log_analytics_solution.LAWsolref.workspace_resource_id
#   exchange_enabled = true
#   depends_on = [
#     azurerm_monitor_diagnostic_setting.example,azurerm_monitor_diagnostic_setting.KVdiag
#   ]
# }


#Microsoft Defender for Endpoint, formerly known as Microsoft Defender Advanced Threat Protection
#------------Defender for endpoint Data connector--------------

# resource "azurerm_sentinel_data_connector_microsoft_defender_advanced_threat_protection" "DC_Endpoint" {
#   name                       = "DefenderForEndpoint"
#   log_analytics_workspace_id = azurerm_log_analytics_solution.LAWsolref.workspace_resource_id
#   depends_on = [
#     azurerm_monitor_diagnostic_setting.example,azurerm_monitor_diagnostic_setting.KVdiag
#   ]
# }
