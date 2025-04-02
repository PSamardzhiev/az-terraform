output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
  sensitive = true
}

output "public_ip_address" {
  value = azurerm_public_ip.aks_public_ip.ip_address
}