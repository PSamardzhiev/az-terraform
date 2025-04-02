resource "azurerm_virtual_network" "vnet" {
  name = var.vnet_name
  resource_group_name = var.rg_name
  location = var.location
  address_space = [var.vnet_address]
}
resource "azurerm_subnet" "subnet" {
  name = var.subnet_name
  resource_group_name = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [var.subnet_address]
}
resource "azurerm_subnet" "BastionSubnet" {
  name = var.bastion_subnet_name
  resource_group_name = var.rg_name
  virtual_network_name = var.vnet_name
  address_prefixes = [ var.bastion_subnet_preffix,]
}
resource azurerm_network_interface "nic" {
  name = var.nic_name
  location = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name = "ipconfig"
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.accedia-pip.id
  }
  depends_on = [ azurerm_public_ip.accedia-pip ]

}

resource "azurerm_public_ip" "accedia-pip" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  idle_timeout_in_minutes = 30
}

resource "azurerm_network_security_group" "accedia-nsg" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.rg_name

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
resource "azurerm_network_interface_security_group_association" "accedia-nsg-association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.accedia-nsg.id
}