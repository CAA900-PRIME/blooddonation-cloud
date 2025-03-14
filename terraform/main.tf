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


resource "azurerm_public_ip" "vm1" {
  name                = "vm1PublicIP"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"
}


resource "azurerm_network_interface" "vm1" {
  name                = "vm1NIC"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "vm1IPConfig"
    subnet_id                     = azurerm_subnet.test.id
    public_ip_address_id          = azurerm_public_ip.vm1.id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "vm1"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  network_interface_ids = [azurerm_network_interface.vm1.id]
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

  computer_name  = "vm1"
  admin_username = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("id_rsa.pub")  
  }

  disable_password_authentication = true
}

resource "azurerm_public_ip" "vm2" {
  name                = "vm2PublicIP"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "vm2" {
  name                = "vm2NIC"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "vm2IPConfig"
    subnet_id                     = azurerm_subnet.test.id
    public_ip_address_id          = azurerm_public_ip.vm2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm2" {
  name                = "vm2"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  network_interface_ids = [azurerm_network_interface.vm2.id]
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

  computer_name  = "vm2"
  admin_username = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("id_rsa.pub")
  }

  disable_password_authentication = true
}
