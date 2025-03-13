terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.24.0"
    }
  }

  required_version = "~> 1.11.2"
}

provider "azurerm" {
  features {}
  subscription_id = "f194cbb4-f8a3-46cc-b71e-f0b4b0b2c17c"
      version = "=4.1.0"
    }
  }
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

# Create a Public IP

resource "azurerm_public_ip" "vm1" {
  name                = "vm1PublicIP"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Basic"
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
  name                  = "vm1"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  network_interface_ids = [azurerm_network_interface.vm1.id]
  size                  = "Standard_B1s"

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
  allocation_method   = "Static"
  sku                 = "Basic"
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
  name                  = "vm2"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  network_interface_ids = [azurerm_network_interface.vm2.id]
  size                  = "Standard_B1s"

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

# Create Network Security Group (NSG)
resource "azurerm_network_security_group" "test" {
  name                = "myNSG"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

# Allow HTTP (Port 80)
resource "azurerm_network_security_rule" "allow_http" {
  name                        = "Allow-HTTP"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.test.name
  network_security_group_name = azurerm_network_security_group.test.name
}

# Allow Port 3000
resource "azurerm_network_security_rule" "allow_3000" {
  name                        = "Allow-3000"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3000"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.test.name
  network_security_group_name = azurerm_network_security_group.test.name
}

# Allow SSH (Port 22)
resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "Allow-SSH"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.test.name
  network_security_group_name = azurerm_network_security_group.test.name
}


# Associate NSG with the network interface
resource "azurerm_network_interface_security_group_association" "assoc1" {
  network_interface_id      = azurerm_network_interface.vm1.id
  network_security_group_id = azurerm_network_security_group.test.id
}

# Associate NSG with the network interface
resource "azurerm_network_interface_security_group_association" "assoc2" {
  network_interface_id      = azurerm_network_interface.vm2.id
  network_security_group_id = azurerm_network_security_group.test.id
}

## OUTPUT IP
output "public_ip1" {
  value       = azurerm_public_ip.vm1.ip_address
  description = "The public IP address of the virtual machine 1"
}

output "public_ip2" {
  value       = azurerm_public_ip.vm2.ip_address
  description = "The public IP address of the virtual machine 2"
}
