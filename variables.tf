variable "rg_name" {
  description = "The name of the Resource Group within which all the resources will be provisioned"
  default     = "SentinelRG-dev1"
}

variable "LAWname" {
  description = "The name of log analytics workspace"
  default = "NewLAWdev04"
}

variable "location" {
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
  default     = "East US"
}


variable "vmuser" {
  description = "Username of VM"
  default = ""
}

variable "vmpass" {
  description = "Password of VM"
  default = ""
}

variable "event_log_name" {

  default = [

    "DFS Replication",
    "Directory Service",
    "Microsoft-Windows-DriverFrameworks-UserMode/Operational",
    "Microsoft-Windows-Firewall-CPL/Diagnostic",
    "Microsoft-Windows-TerminalServices-LocalSessionManager/Operational",
    "Microsoft-Windows-TerminalServices-RemoteConnectionManager/Admin",
    "Microsoft-Windows-TerminalServices-SessionBroker-Client/Admin",
    "Microsoft-Windows-TerminalServices-SessionBroker-Client/Operational",
    "Microsoft-Windows-Windows Firewall with Advanced Security/ConnectionSecurity",
    "Microsoft-Windows-Windows Firewall with Advanced Security/ConnectionSecurityVerbose",
    "Microsoft-Windows-Windows Firewall with Advanced Security/Firewall",
    "Microsoft-Windows-Windows Firewall with Advanced Security/FirewallVerbose",
    "System"
  ]

}



variable "example-lad-wpc" {
  default = ["agent1", "agent2", "agent3",
    "agent4", "agent5", "agent6",
    "agent7", "agent8", "agent9",
  "agent10", "agent11", "agent12", "agent13"]
}


variable "nsg_log_category" {
default = ["NetworkSecurityGroupEvent", "NetworkSecurityGroupRuleCounter"]
}

variable "kv_log_category" {
  default = ["AuditEvent","AzurePolicyEvaluationDetails"]
}


#---------------Variables for azue active directory--------------

variable "azure_sentinel_rule_template_scheduled_AAD_displaynames" {
  description = "Displaynames for Azure Active Directory rules that want to applied"
  default = [
      "Modified domain federation trust settings",
      "First access credential added to Application or Service Principal where no credential was present",
      "Suspicious application consent similar to O365 Attack Toolkit",
      "Brute force attack against Azure Portal",
      "MFA disabled for a user",
      "Password spray attack against Azure AD application",
      "Rare application consent",
      "Credential added after admin consented to Application",
      "Mail.Read Permissions Granted to Application",
      "Sign-ins from IPs that attempt sign-ins to disabled accounts",
      "Successful logon from IP and failure from a different IP",
      "Explicit MFA Deny",
      "Failed AzureAD logons but success logon to host",
      "Anomalous sign-in location by user account and authenticating application",
      "Attempts to sign in to disabled accounts",
      "Distributed Password cracking attempts in AzureAD",
      "Anomalous login followed by Teams action",
      "User added to Azure Active Directory Privileged Groups",
      "Suspicious application consent similar to PwnAuth",
      "Failed host logons but success logon to AzureAD",
      "New access credential added to Application or Service Principal",
      "Suspicious application consent for offline access",
      "Failed login attempts to Azure Portal",
      "Azure Active Directory PowerShell accessing non-AAD resources",
      "Attempt to bypass conditional access rule in Azure AD",
      "RDP Nesting",
  ]
}

# variable "automation_location" {
#   description = "Region of the automation account"
#   default = "EASTUS2"
# }

