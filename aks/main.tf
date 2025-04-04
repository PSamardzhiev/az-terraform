
resource "azurerm_public_ip" "aks_public_ip" {
  name                = "${var.aks_cluster_name}-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.aks_cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  
  default_node_pool {
    name           = "agentpool"
    vm_size        = var.vm_size
    node_count     = var.node_count
    os_disk_size_gb = var.os_disk_size_gb
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

  network_profile {
    load_balancer_sku = "standard"
    network_plugin       = "azure"
    network_plugin_mode  = "overlay"
    load_balancer_profile {
      outbound_ip_address_ids = [azurerm_public_ip.aks_public_ip.id,]
    }
  }
}