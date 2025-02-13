terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "myResourceGroup"
  location = "East US"
}


resource "azurerm_virtual_network" "test" {
  name                = "myVNet"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}


resource "azurerm_subnet" "test" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}


resource "azurerm_public_ip" "test" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"
}


resource "azurerm_network_interface" "test" {
  name                = "myNIC"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "myIPConfig"
    subnet_id                     = azurerm_subnet.test.id
    public_ip_address_id          = azurerm_public_ip.test.id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_linux_virtual_machine" "test" {
  name                = "myAzureVM"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  network_interface_ids = [azurerm_network_interface.test.id]
  size                = "Standard_B1s"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  computer_name  = "myvm"
  admin_username = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("C:/Users/User/terraform-azure/id_rsa.pub")  
  }

  disable_password_authentication = true
}
