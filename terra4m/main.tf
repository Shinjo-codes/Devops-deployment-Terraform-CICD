provider "azurerm" {

  features {}

}


# =========================================


# Resource Group

# =========================================


resource "azurerm_resource_group" "rg" {

  name     = "rg-php-devops"

  location = "West US 3"

}


# =========================================

# Virtual Network

# =========================================


resource "azurerm_virtual_network" "vnet" {

  name                = "vnet-php"

  address_space       = ["10.0.0.0/16"]

  location            = azurerm_resource_group.rg.location

  resource_group_name = azurerm_resource_group.rg.name

}


# =========================================

# Subnet

# =========================================


resource "azurerm_subnet" "subnet" {

  name                 = "subnet-php"

  resource_group_name  = azurerm_resource_group.rg.name

  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes     = ["10.0.1.0/24"]

}


# =========================================

# Network Security Group

# =========================================


resource "azurerm_network_security_group" "nsg" {

  name                = "nsg-php"

  location            = azurerm_resource_group.rg.location

  resource_group_name = azurerm_resource_group.rg.name


  # SSH

  security_rule {

    name                       = "SSH"

    priority                   = 1001

    direction                  = "Inbound"

    access                     = "Allow"

    protocol                   = "Tcp"

    source_port_range          = "*"

    destination_port_range     = "22"

    source_address_prefix      = "*"

    destination_address_prefix = "*"

  }


  # HTTP

  security_rule {

    name                       = "HTTP"

    priority                   = 1002

    direction                  = "Inbound"

    access                     = "Allow"

    protocol                   = "Tcp"

    source_port_range          = "*"

    destination_port_range     = "80"

    source_address_prefix      = "*"

    destination_address_prefix = "*"

  }


  # HTTPS

  security_rule {

    name                       = "HTTPS"

    priority                   = 1003

    direction                  = "Inbound"

    access                     = "Allow"

    protocol                   = "Tcp"

    source_port_range          = "*"

    destination_port_range     = "443"

    source_address_prefix      = "*"

    destination_address_prefix = "*"

  }


  # Docker Application Port

  security_rule {

    name                       = "AllowDocker"

    priority                   = 1004

    direction                  = "Inbound"

    access                     = "Allow"

    protocol                   = "Tcp"

    source_port_range          = "*"

    destination_port_range     = "3000"

    source_address_prefix      = "*"

    destination_address_prefix = "*"

  }

}


# =========================================

# Public IP

# =========================================


resource "azurerm_public_ip" "pip" {

  name                = "php-public-ip"

  location            = azurerm_resource_group.rg.location

  resource_group_name = azurerm_resource_group.rg.name

  allocation_method   = "Static"

}


# =========================================

# Network Interface

# =========================================


resource "azurerm_network_interface" "nic" {

  name                = "php-nic"

  location            = azurerm_resource_group.rg.location

  resource_group_name = azurerm_resource_group.rg.name


  depends_on = [

    azurerm_subnet.subnet

  ]


  ip_configuration {

    name                          = "internal"

    subnet_id                     = azurerm_subnet.subnet.id

    private_ip_address_allocation = "Dynamic"

    public_ip_address_id          = azurerm_public_ip.pip.id

  }

}


# =========================================

# Attach NSG to NIC

# =========================================


resource "azurerm_network_interface_security_group_association" "assoc" {

  network_interface_id      = azurerm_network_interface.nic.id

  network_security_group_id = azurerm_network_security_group.nsg.id

}


# =========================================

# Linux Virtual Machine

# =========================================


resource "azurerm_linux_virtual_machine" "vm" {

  name                = "php-vm"

  resource_group_name = azurerm_resource_group.rg.name

  location            = azurerm_resource_group.rg.location

  size                = "Standard_D2s_v3"

  admin_username      = "azureuser"


  network_interface_ids = [

    azurerm_network_interface.nic.id

  ]


  depends_on = [

    azurerm_network_interface_security_group_association.assoc

  ]


  admin_ssh_key {

    username   = "azureuser"

    public_key = file("~/.ssh/azure_key.pub")

  }


  os_disk {

    caching              = "ReadWrite"

    storage_account_type = "Standard_LRS"

  }


  source_image_reference {

    publisher = "Canonical"

    offer     = "0001-com-ubuntu-server-jammy"

    sku       = "22_04-lts"

    version   = "latest"

  }

}