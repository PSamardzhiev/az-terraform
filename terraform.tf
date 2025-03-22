terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "accedia_rg" {
  name     = "AccediaTFRG"
  location = "West Europe"
}

resource "azurerm_virtual_network" "Accedia_TF_Network" {
  name                = "Accedia-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.accedia_rg.location
  resource_group_name = azurerm_resource_group.accedia_rg.name
}

resource "azurerm_subnet" "accedia_test_subnet" {
  name                 = "accedia-subnet"
  resource_group_name  = azurerm_resource_group.accedia_rg.name
  virtual_network_name = azurerm_virtual_network.Accedia_TF_Network.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "accedia-nsg" {
  name                = "AccediaTestNSG"
  location            = azurerm_resource_group.accedia_rg.location
  resource_group_name = azurerm_resource_group.accedia_rg.name

  security_rule {
    name                       = "Allow_Outbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow_80_Inbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "80"
    destination_address_prefix = "*"
  }
   security_rule {
    name                       = "Allow_SSH_Inbound"
    priority                   = 250
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "22"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow_443_Inbound"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "443"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 600
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface" "vnic" {
  name                = "test-nic"
  location            = azurerm_resource_group.accedia_rg.location
  resource_group_name = azurerm_resource_group.accedia_rg.name

  ip_configuration {
    name                          = "InternalIP"
    subnet_id                     = azurerm_subnet.accedia_test_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.PubNic.id

  }
}
resource "azurerm_network_interface_security_group_association" "nsg-attach" {
  network_interface_id      = azurerm_network_interface.vnic.id
  network_security_group_id = azurerm_network_security_group.accedia-nsg.id
}

resource "azurerm_linux_virtual_machine" "Ubuntu-VM" {
  name                = "Ubuntu-vm"
  resource_group_name = azurerm_resource_group.accedia_rg.name
  location            = azurerm_resource_group.accedia_rg.location
  size                = "Standard_DC1s_v2"
  admin_username      = "azureadmin"
  network_interface_ids = [
    azurerm_network_interface.vnic.id,
  ]

  admin_ssh_key {
    username   = "azureadmin"
    public_key = file("~/.ssh/id_rsa.pub")
  }

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
}

resource "azurerm_public_ip" "PubNic" {
  name                    = "TestPubIP"
  resource_group_name     = azurerm_resource_group.accedia_rg.name
  location                = azurerm_resource_group.accedia_rg.location
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30
}
output "azurerm_network_interface" {
  value = "${azurerm_public_ip.PubNic.*.ip_address}"
}
