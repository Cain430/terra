provider "azurerm" {
  features {
    
  }
}
# Azure Storage Account Backend
terraform {
  backend "azurerm" {
    storage_account_name = "storage"
    container_name       = "name"
    key                  = "path/to/terraform.tfstate"
  }
}
resource "azurerm_resource_group" "resource" {
  name     = "jasser_recource"
  location = "West Europe"
}

resource "azurerm_virtual_network" "net" {
  name                = "jassernetwork"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.resource.location
  resource_group_name = azurerm_resource_group.resource.name
}

resource "azurerm_network_security_group" "secure" {
  name                = "jasser-secure"
  location            = azurerm_resource_group.resource.location
  resource_group_name = azurerm_resource_group.resource.name
}

resource "azurerm_subnet" "sub" {
  name                 = "jasser_subnet"
  resource_group_name  = azurerm_resource_group.resource.name
  virtual_network_name = azurerm_virtual_network.net.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "ipad" {
  name                = "jassser-public-ip"
  location            = azurerm_resource_group.resource.location
  resource_group_name = azurerm_resource_group.resource.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "netw" {
  name                = "jassser"
  location            = azurerm_resource_group.resource.location
  resource_group_name = azurerm_resource_group.resource.name

  ip_configuration {
    name                          = "config"
    subnet_id                     = azurerm_subnet.sub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ipad.id
  }
}

resource "azurerm_linux_virtual_machine" "virtual" {
  name                = "vagrant"
  resource_group_name = azurerm_resource_group.resource.name
  location            = azurerm_resource_group.resource.location
  size                = "Standard_DS1_v2"
  admin_username      = "cain"
  admin_password      = "Wasteofspace1*"

  network_interface_ids = [azurerm_network_interface.netw.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}