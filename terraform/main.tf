terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = ""
}

resource "azurerm_resource_group" "test" {
  name     = "myResourceGroup"
  location = "East US"
}

# Create the Virtual Network
resource "azurerm_virtual_network" "test" {
  name                = "myVNet"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

# Create a Subnet
resource "azurerm_subnet" "test" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a Public IP
resource "azurerm_public_ip" "test" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Basic"
}

# Create the Network Interface
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

# Create the Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "test" {
  name                  = "myAzureVM"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  network_interface_ids = [azurerm_network_interface.test.id]
  size                  = "Standard_B2s"

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
  admin_username = "ubuntu"

  admin_ssh_key {
    username   = "ubuntu"
    public_key = file("bd_key.pub") # Ensure this file exists and correct name
  }

  disable_password_authentication = true
  depends_on                      = [azurerm_public_ip.test]

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y docker.io",
      "sudo apt-get install -y vim",
      "sudo apt-get install -y tmux",
      "sudo apt install -y python3 python3-pip python3-venv python3-dev",
      "sudo apt-get install -y nodejs",
      "echo 'export TERM=xterm-256color' >> ~/.bashrc", # To enable tmux
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ubuntu"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("bd_key")
      host        = azurerm_public_ip.test.ip_address
      timeout     = "5m"
    }
  }
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
resource "azurerm_network_interface_security_group_association" "test" {
  network_interface_id      = azurerm_network_interface.test.id
  network_security_group_id = azurerm_network_security_group.test.id
}

## OUTPUT IP
output "public_ip" {
  value       = azurerm_public_ip.test.ip_address
  description = "The public IP address of the virtual machine"
}
