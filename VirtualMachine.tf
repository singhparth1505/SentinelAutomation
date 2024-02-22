#--------------------Virtual network------------
resource "azurerm_virtual_network" "vnet01" {
  name                = "demovnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.RGref.location
  resource_group_name = azurerm_resource_group.RGref.name

  depends_on = [
    azurerm_network_security_group.NSGref
  ]
}
#--------------------Subnet------------
resource "azurerm_subnet" "snet01" {
  name                 = "demosnet"
  resource_group_name  = azurerm_resource_group.RGref.name
  virtual_network_name = azurerm_virtual_network.vnet01.name
  address_prefixes     = ["10.0.2.0/24"]

  depends_on = [
    azurerm_virtual_network.vnet01
  ]
}

#Public IP for the VM
resource "azurerm_public_ip" "pip_demo" {
  name                = "SentinelPip"
  resource_group_name = azurerm_resource_group.RGref.name
  location            = azurerm_resource_group.RGref.location
  allocation_method   = "Dynamic"

  
}

#--------------------network interface card------------
resource "azurerm_network_interface" "nic01" {
  name                = "demonic"
  location            = azurerm_resource_group.RGref.location
  resource_group_name = azurerm_resource_group.RGref.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet01.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip_demo.id
  }
}
#--------------------Virtual Machine------------
resource "azurerm_windows_virtual_machine" "vm01" {
  name                = "demoVM2019"
  resource_group_name = azurerm_resource_group.RGref.name
  location            = azurerm_resource_group.RGref.location
  size                = "Standard_D4s_v3" #Standard_F2
  admin_username      = var.vmuser
  admin_password      = var.vmpass
  network_interface_ids = [
    azurerm_network_interface.nic01.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
identity {
  type = "SystemAssigned"
}
  depends_on = [
    azurerm_subnet.snet01
  ]
}
#--------AMAagentInstallation-----------
 resource "azurerm_virtual_machine_extension" "AzureMonitorWinAgent" {        
      name                       = "AzureMonitorWinAgent"
      publisher                  = "Microsoft.Azure.Monitor"
      type                       = "AzureMonitorWindowsAgent"
      type_handler_version       = 1.12
      auto_upgrade_minor_version = "true"
    
      virtual_machine_id = azurerm_windows_virtual_machine.vm01.id
    }
#--------------------NSG-NIC association------------
resource "azurerm_network_interface_security_group_association" "nsgnic01" {
  network_interface_id      = azurerm_network_interface.nic01.id
  network_security_group_id = azurerm_network_security_group.NSGref.id
  depends_on = [
    azurerm_windows_virtual_machine.vm01
  ]
}