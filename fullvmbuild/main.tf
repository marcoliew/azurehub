    # Configure the Azure provider
provider "azurerm" {
    # The "feature" block is required for AzureRM provider 2.x.
    features {}
}
variable "prefix" {
  default = "tfvmex"
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_account" "main" {
  name                     = "omstesttest22"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = "westus"
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_log_analytics_workspace" "law02" {
  name                = "${var.prefix}-logAnalytics"
 location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
 sku                 = "PerGB2018"
  retention_in_days   = 30
}



resource "azurerm_log_analytics_solution" "example" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  workspace_resource_id = azurerm_log_analytics_workspace.law02.id
  workspace_name        = azurerm_log_analytics_workspace.law02.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

#===================================================================
# Set Monitoring and Log Analytics Workspace
#===================================================================
resource "azurerm_virtual_machine_extension" "oms_mma02" {
  name                       = "test-OMSExtension"
virtual_machine_id         =  azurerm_virtual_machine.main.id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "OmsAgentForLinux"
  type_handler_version       = "1.12"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "workspaceId" : "${azurerm_log_analytics_workspace.law02.workspace_id}"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "workspaceKey" : "${azurerm_log_analytics_workspace.law02.primary_shared_key}"
    }
  PROTECTED_SETTINGS
}