resource "azurerm_monitor_data_collection_rule" "linuxlogdcrule" {
  name                = "sentinel-linuxlogcollector-dcr"
  resource_group_name = azurerm_resource_group.RGref.name
  location            = var.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.LAWref.id
      name                  = "linuxlog-destination"
    }

  }

  data_flow {
    streams      = ["Microsoft-Syslog", "Microsoft-Perf","Microsoft-WindowsEvent"]
    destinations = ["linuxlog-destination"]
  }

  data_sources {
    syslog {
      facility_names = ["auth","authpriv","cron","daemon","kern","local0","local1","local2","local3","local4","local5","local6","local7","syslog","user"]
      log_levels     = ["Info","Notice","Warning","Error","Critical","Alert","Emergency"]
      name           = "linuxlogcollector-dcr"
    }
  }

  depends_on = [
    null_resource.jsonplaybook
  ]
}

resource "azurerm_monitor_data_collection_rule" "linuxserverdcrule" {
  name                = "sentinel-linuxservers-dcr"
  resource_group_name = azurerm_resource_group.RGref.name
  location            = var.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.LAWref.id
      name                  = "linuxservers-destination"
    }

  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["linuxservers-destination"]
  }

  data_sources {

syslog {
      facility_names = ["auth","authpriv","cron","daemon","syslog","user"]
      log_levels     = ["Info","Notice","Warning","Error","Critical","Alert","Emergency"]
      name           = "linuxservers-dcr"
    }
  }

  depends_on = [
    azurerm_monitor_data_collection_rule.linuxlogdcrule
  ]
}

resource "azurerm_monitor_data_collection_rule" "perfcountersdcrule" {
  name                = "sentinel-perfcounters-dcr"
  resource_group_name = azurerm_resource_group.RGref.name
  location            = var.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.LAWref.id
      name                  = "perfcounters-destination"
    }

  }

  data_flow {
    streams      = ["Microsoft-Perf"]
    destinations = ["perfcounters-destination"]
  }

  data_sources {

    performance_counter {
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 15
      counter_specifiers            = [
          "Processor(*)\\% Processor Time",
            "Processor(*)\\% Idle Time",
            "Processor(*)\\% User Time",
            "Processor(*)\\% Nice Time",
            "Processor(*)\\% Privileged Time",
            "Processor(*)\\% IO Wait Time",
            "Processor(*)\\% Interrupt Time",
            "Processor(*)\\% DPC Time",
            "\\Processor Information(*)\\% Processor Time",
            "\\Processor Information(*)\\% Privileged Time",
            "\\Processor Information(*)\\% User Time",
            "\\Processor Information(*)\\Processor Frequency",
            "\\System\\Processes",
            "\\Process(*)\\Thread Count",
            "\\Process(*)\\Handle Count",
            "\\System\\System Up Time",
            "\\System\\Context Switches/sec",
            "\\System\\Processor Queue Length",
            "Memory(*)\\Available MBytes Memory",
            "Memory(*)\\% Available Memory",
            "Memory(*)\\Used Memory MBytes",
            "Memory(*)\\% Used Memory",
            "Memory(*)\\Pages/sec",
            "Memory(*)\\Page Reads/sec",
            "Memory(*)\\Page Writes/sec",
            "Memory(*)\\Available MBytes Swap",
            "Memory(*)\\% Available Swap Space",
            "Memory(*)\\Used MBytes Swap Space",
            "Memory(*)\\% Used Swap Space",
            "\\Memory\\% Committed Bytes In Use",
            "\\Memory\\Available Bytes",
            "\\Memory\\Committed Bytes",
            "\\Memory\\Cache Bytes",
            "\\Memory\\Pool Paged Bytes",
            "\\Memory\\Pool Nonpaged Bytes",
            "\\Memory\\Pages/sec",
            "\\Memory\\Page Faults/sec",
            "\\Process(*)\\Working Set",
            "\\Process(*)\\Working Set - Private",
            "Logical Disk(*)\\% Free Inodes",
            "Logical Disk(*)\\% Used Inodes",
            "Logical Disk(*)\\Free Megabytes",
            "Logical Disk(*)\\% Free Space",
            "Logical Disk(*)\\% Used Space",
            "Logical Disk(*)\\Logical Disk Bytes/sec",
            "Logical Disk(*)\\Disk Read Bytes/sec",
            "Logical Disk(*)\\Disk Write Bytes/sec",
            "Logical Disk(*)\\Disk Transfers/sec",
            "Logical Disk(*)\\Disk Reads/sec",
            "Logical Disk(*)\\Disk Writes/sec",
            "\\LogicalDisk(*)\\% Disk Time",
            "\\LogicalDisk(*)\\% Disk Read Time",
            "\\LogicalDisk(*)\\% Disk Write Time",
            "\\LogicalDisk(*)\\% Idle Time",
            "\\LogicalDisk(*)\\Disk Bytes/sec",
            "\\LogicalDisk(*)\\Disk Read Bytes/sec",
            "\\LogicalDisk(*)\\Disk Write Bytes/sec",
            "\\LogicalDisk(*)\\Disk Transfers/sec",
            "\\LogicalDisk(*)\\Disk Reads/sec",
            "\\LogicalDisk(*)\\Disk Writes/sec",
            "\\LogicalDisk(*)\\Avg. Disk sec/Transfer",
            "\\LogicalDisk(*)\\Avg. Disk sec/Read",
            "\\LogicalDisk(*)\\Avg. Disk sec/Write",
            "\\LogicalDisk(*)\\Avg. Disk Queue Length",
            "\\LogicalDisk(*)\\Avg. Disk Read Queue Length",
            "\\LogicalDisk(*)\\Avg. Disk Write Queue Length",
            "\\LogicalDisk(*)\\% Free Space",
            "\\LogicalDisk(*)\\Free Megabytes",
            "Network(*)\\Total Bytes Transmitted",
            "Network(*)\\Total Bytes Received",
            "Network(*)\\Total Bytes",
            "Network(*)\\Total Packets Transmitted",
            "Network(*)\\Total Packets Received",
            "Network(*)\\Total Rx Errors",
            "Network(*)\\Total Tx Errors",
            "Network(*)\\Total Collisions",
            "\\Network Interface(*)\\Bytes Total/sec",
            "\\Network Interface(*)\\Bytes Sent/sec",
            "\\Network Interface(*)\\Bytes Received/sec",
            "\\Network Interface(*)\\Packets/sec",
            "\\Network Interface(*)\\Packets Sent/sec",
            "\\Network Interface(*)\\Packets Received/sec",
            "\\Network Interface(*)\\Packets Outbound Errors",
            "\\Network Interface(*)\\Packets Received Errors"]
      name                          = "perfcounters-dcr"
    }
  }

  depends_on = [
    azurerm_monitor_data_collection_rule.linuxserverdcrule
  ]
}

resource "azurerm_monitor_data_collection_rule" "wincollectordcrule" {
  name                = "sentinel-wineventcollector-dcr"
  resource_group_name = azurerm_resource_group.RGref.name
  location            = var.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.LAWref.id
      name                  = "wincollector-destination"
    }

  }

  data_flow {
    streams      = ["Microsoft-WindowsEvent"]
    destinations = ["wincollector-destination"]
  }
  data_sources {
    windows_event_log {
      streams        = ["Microsoft-WindowsEvent"]
      x_path_queries = ["ForwardedEvents!*",
            "Security!*[System[(EventID=4720 or EventID=4722 or EventID=4723 or EventID=4724 or EventID=4725 or EventID=4726 or EventID=4738 or EventID=4741 or EventID=4742 or EventID=4743 or EventID=4624 or EventID=4625 or EventID=4768 or EventID=4769 or EventID=4771 or EventID=4776 or EventID=4648 or EventID=4778)]]",
            "Security!*[System[(EventID=4672 or EventID=4740 or EventID=4964 or EventID=4706 or EventID=4707 or EventID=4716 or EventID=4713 or EventID=4717 or EventID=4718 or EventID=4739 or EventID=4727 or EventID=4728 or EventID=4729 or EventID=4731 or EventID=4732 or EventID=4734 or EventID=4735 or EventID=4737 or EventID=4754)]]",
            "Security!*[System[(EventID=4755 or EventID=4756 or EventID=4757 or EventID=4758 or EventID=5140 or EventID=5142 or EventID=5143 or EventID=5144 or EventID=4656 or EventID=4660 or EventID=4661 or EventID=4663 or EventID=4670 or EventID=4698 or EventID=4699 or EventID=4700 or EventID=4701 or EventID=4702 or EventID=4688)]]",
            "Security!*[System[(EventID=4657 or EventID=517 or EventID=1102 or EventID=4946 or EventID=4947 or EventID=4950 or EventID=4954 or EventID=5025 or EventID=5031 or EventID=4673 or EventID=4674 or EventID=5136 or EventID=4733 or EventID=4753 or EventID=4763 or EventID=4649 or EventID=4704 or EventID=4719 or EventID=4767)]]",
            "Security!*[System[(EventID=4797 or EventID=4799 or EventID=4904 or EventID=4905 or EventID=4907 or EventID=4948 or EventID=6416 or EventID=6423 or EventID=6424 or EventID=5145 or EventID=4697)]]",
            "System!*[System[(EventID=7045)]]",
            "Security!*[System[(EventID=4705)]] and *[EventData[Data[@Name='SubjectUserSid']!='SYSTEM']]",
            "Microsoft-Windows-NTLM/Operational!*[System[(EventID=8004)]]",
            "Microsoft-Windows-Eventlog!*[System[(EventID=1100)]]"]
      name           = "windowseventcollectors-dcr"
    }

  }

  depends_on = [
    azurerm_monitor_data_collection_rule.perfcountersdcrule
  ]
}

resource "azurerm_monitor_data_collection_rule" "winserversdcrule" {
  name                = "sentinel-winservers-dcr"
  resource_group_name = azurerm_resource_group.RGref.name
  location            = var.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.LAWref.id
      name                  = "winservers-destination"
    }

  }

  data_flow {
    streams      = ["Microsoft-WindowsEvent"]
    destinations = ["winservers-destination"]
  }

  data_sources {
    windows_event_log {
      streams        = ["Microsoft-WindowsEvent"]
      x_path_queries = ["Security!*[System[(EventID=4720 or EventID=4722 or EventID=4723 or EventID=4724 or EventID=4725 or EventID=4726 or EventID=4738 or EventID=4741 or EventID=4742 or EventID=4743 or EventID=4624 or EventID=4625 or EventID=4768 or EventID=4769 or EventID=4771 or EventID=4776 or EventID=4648 or EventID=4778)]]",
            "Security!*[System[(EventID=4672 or EventID=4740 or EventID=4964 or EventID=4706 or EventID=4707 or EventID=4716 or EventID=4713 or EventID=4717 or EventID=4718 or EventID=4739 or EventID=4727 or EventID=4728 or EventID=4729 or EventID=4731 or EventID=4732 or EventID=4734 or EventID=4735 or EventID=4737 or EventID=4754)]]",
            "Security!*[System[(EventID=4755 or EventID=4756 or EventID=4757 or EventID=4758 or EventID=5140 or EventID=5142 or EventID=5143 or EventID=5144 or EventID=4656 or EventID=4660 or EventID=4661 or EventID=4663 or EventID=4670 or EventID=4698 or EventID=4699 or EventID=4700 or EventID=4701 or EventID=4702 or EventID=4688)]]",
            "Security!*[System[(EventID=4657 or EventID=517 or EventID=1102 or EventID=4946 or EventID=4947 or EventID=4950 or EventID=4954 or EventID=5025 or EventID=5031 or EventID=4673 or EventID=4674 or EventID=5136 or EventID=4733 or EventID=4753 or EventID=4763 or EventID=4649 or EventID=4704 or EventID=4719 or EventID=4767)]]",
            "Security!*[System[(EventID=4797 or EventID=4799 or EventID=4904 or EventID=4905 or EventID=4907 or EventID=4948 or EventID=6416 or EventID=6423 or EventID=6424 or EventID=5145 or EventID=4697)]]",
            "System!*[System[(EventID=7045)]]",
            "Security!*[System[(EventID=4705)]] and *[EventData[Data[@Name='SubjectUserSid']!='SYSTEM']]",
            "Microsoft-Windows-NTLM/Operational!*[System[(EventID=8004)]]",
            "Microsoft-Windows-Eventlog!*[System[(EventID=1100)]]"]
      name           = "windowsservers-dcr"
    }

   
  }

  depends_on = [
    azurerm_monitor_data_collection_rule.wincollectordcrule
  ]
}

#------DC rule association with resources----------
resource "azurerm_monitor_data_collection_rule_association" "DCassoc1" {
  name                    = "perf-assoc"
  target_resource_id      = azurerm_windows_virtual_machine.vm01.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.perfcountersdcrule.id
  description             = "performance counter association with virtual machine"
}

resource "azurerm_monitor_data_collection_rule_association" "DCassoc2" {
  name                    = "wincollector-assoc"
  target_resource_id      = azurerm_windows_virtual_machine.vm01.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.wincollectordcrule.id
  description             = "Windows collector association with virtual machine"
}

resource "azurerm_monitor_data_collection_rule_association" "DCassoc3" {
  name                    = "winserver-assoc"
  target_resource_id      = azurerm_windows_virtual_machine.vm01.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.winserversdcrule.id
  description             = "Windows server association with virtual machine"
}