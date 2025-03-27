output "network_interface_id" {
  value = azurerm_network_interface.nic.id
}

output "public_ip_address" {
  value = azurerm_public_ip.accedia-pip.ip_address
}