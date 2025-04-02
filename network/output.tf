output "network_interface_id" {
  value = azurerm_network_interface.nic.id
}

output "public_ip_address" {
  value = azurerm_public_ip.accedia-pip.ip_address
}
output "bastion_pip" {
  value = azurerm_public_ip.bastion-pip.ip_address
  
}
output "bastion_network_id" {
  value = azurerm_subnet.BastionSubnet.id
}

output "bastion_pip_id" {
  value = azurerm_public_ip.bastion-pip.id
  
}