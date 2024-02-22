resource "azurerm_policy_definition" "policydefinition" {
  name        = "PolicyDefinitionTerraform"
  policy_type = "Custom"
  mode        = "All"
 display_name = "Configure Azure Activity logs to stream to specified Log Analytics workspace"
 description = "Deploys the diagnostic settings for Azure Activity to stream subscriptions audit logs to a Log Analytics workspace to monitor subscription-level events"
 policy_rule = <<POLICY_RULE
    {
    "if": {
        "field": "type",
        "equals": "Microsoft.Resources/subscriptions"
      },
    "then": {
        "effect": "[parameters('effect')]",
        "details": {
          "type": "Microsoft.Insights/diagnosticSettings",
          "deploymentScope": "Subscription",
          "existenceScope": "Subscription",
          "existenceCondition": {
            "allOf": [
              {
                "field": "Microsoft.Insights/diagnosticSettings/logs.enabled",
                "equals": "[parameters('logsEnabled')]"
              },
              {
                "field": "Microsoft.Insights/diagnosticSettings/workspaceId",
                "equals": "[parameters('logAnalytics')]"
              }
            ]
          },
          "deployment": {
            "location": "northeurope",
            "properties": {
              "mode": "incremental",
              "template": {
                "$schema": "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#",
                "contentVersion": "1.0.0.0",
                "parameters": {
                  "logAnalytics": {
                    "type": "string"
                  },
                  "logsEnabled": {
                    "type": "string"
                  }
                },
                "variables": {},
                "resources": [
                  {
                    "name": "subscriptionToLa",
                    "type": "Microsoft.Insights/diagnosticSettings",
                    "apiVersion": "2017-05-01-preview",
                    "location": "Global",
                    "properties": {
                      "workspaceId": "[parameters('logAnalytics')]",
                      "logs": [
                        {
                          "category": "Administrative",
                          "enabled": "[parameters('logsEnabled')]"
                        },
                        {
                          "category": "Security",
                          "enabled": "[parameters('logsEnabled')]"
                        },
                        {
                          "category": "ServiceHealth",
                          "enabled": "[parameters('logsEnabled')]"
                        },
                        {
                          "category": "Alert",
                          "enabled": "[parameters('logsEnabled')]"
                        },
                        {
                          "category": "Recommendation",
                          "enabled": "[parameters('logsEnabled')]"
                        },
                        {
                          "category": "Policy",
                          "enabled": "[parameters('logsEnabled')]"
                        },
                        {
                          "category": "Autoscale",
                          "enabled": "[parameters('logsEnabled')]"
                        },
                        {
                          "category": "ResourceHealth",
                          "enabled": "[parameters('logsEnabled')]"
                        }
                      ]
                    }
                  }
                ],
                "outputs": {}
              },
              "parameters": {
                "logAnalytics": {
                  "value": "[parameters('logAnalytics')]"
                },
                "logsEnabled": {
                  "value": "[parameters('logsEnabled')]"
                }
              }
            }
          },
          "roleDefinitionIds": [
            "/providers/microsoft.authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa",
            "/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293"
          ]
        }
  }
  }
POLICY_RULE


  parameters = <<PARAMETERS
    {
     "logAnalytics": {
        "type": "String",
        "metadata": {
          "displayName": "Primary Log Analytics workspace",
          "description": "If this workspace is outside of the scope of the assignment you must manually grant 'Log Analytics Contributor' permissions (or similar) to the policy assignment's principal ID.",
          "strongType": "omsWorkspace",
          "assignPermissions": true
        }
      },
      "effect": {
        "type": "String",
        "metadata": {
          "displayName": "Effect",
          "description": "Enable or disable the execution of the policy"
        },
        "allowedValues": [
          "DeployIfNotExists",
          "Disabled"
        ],
        "defaultValue": "DeployIfNotExists"
      },
      "logsEnabled": {
        "type": "String",
        "metadata": {
          "displayName": "Enable logs",
          "description": "Whether to enable logs stream to the Log Analytics workspace - True or False"
        },
        "allowedValues": [
          "True",
          "False"
        ],
        "defaultValue": "True"
      }
      }
PARAMETERS

depends_on = [
  azurerm_log_analytics_datasource_windows_event.example01
]
}

resource "azurerm_resource_group_policy_assignment" "policyassign" {
  name                 = "ResourceGrouppolicy-assignment"
  resource_group_id    = azurerm_resource_group.RGref.id
  //scope                = azurerm_resource_group.RGref.id
  policy_definition_id = azurerm_policy_definition.policydefinition.id
  description = "Policy Assignment created"
  display_name         = "Configure Azure Activity logs to stream to specified Log Analytics workspace"
identity {
     type = "SystemAssigned"
  }

  location = "EAST US"
  parameters = <<PARAMETERS
{
  "logAnalytics": {
    "value": "${azurerm_log_analytics_workspace.LAWref.id}"
  }
}
PARAMETERS
depends_on = [azurerm_policy_definition.policydefinition,azurerm_log_analytics_workspace.LAWref]

}

 resource "azurerm_resource_group_policy_remediation" "example" {
  name                 = "policy-remediation"
  resource_group_id    = azurerm_resource_group.RGref.id
  policy_assignment_id = azurerm_resource_group_policy_assignment.policyassign.id
  location_filters = ["EAST US"]

  depends_on = [
    azurerm_resource_group_policy_assignment.policyassign
  ]
}