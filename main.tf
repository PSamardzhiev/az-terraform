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

locals {
  json_vars = jsondecode(file("${path.module}/variables.json"))
}

resource "azurerm_resource_group" "rg_name" {
  name     = local.json_vars.general.rg_name
  location = local.json_vars.general.location
}

module "network" {
  source         = "./network"
  rg_name        = azurerm_resource_group.rg_name.name
  location       = azurerm_resource_group.rg_name.location
  vnet_name      = local.json_vars.network.vnet_name
  subnet_name    = local.json_vars.network.subnet_name
  vnet_address   = local.json_vars.network.vnet_address
  subnet_address = local.json_vars.network.subnet_address
  nsg_name       = local.json_vars.network.nsg_name
  nic_name       = local.json_vars.network.nic_name
  public_ip_name = local.json_vars.network.public_ip_name
}
module "vm" {
  source               = "./vm"
  rg_name              = azurerm_resource_group.rg_name.name
  location             = azurerm_resource_group.rg_name.location
  publisher            = local.json_vars.vm.publisher
  vm_version           = local.json_vars.vm.vm_version
  offer                = local.json_vars.vm.offer
  sku                  = local.json_vars.vm.sku
  admin_username       = local.json_vars.vm.admin_username
  admin_password       = local.json_vars.vm.admin_password
  vm_size              = local.json_vars.vm.vm_size
  vm_name              = local.json_vars.vm.vm_name
  network_interface_id = module.network.network_interface_id
  admin_ssh_username   = local.json_vars.ssh_key.admin_ssh_username
  public_key_path      = local.json_vars.ssh_key.public_key_path
}
module "aks" {
  source = "./aks"
  location = local.json_vars.general.location
  resource_group_name = local.json_vars.general.rg_name
  aks_cluster_name = local.json_vars.aks.aks_cluster_name
  dns_prefix = local.json_vars.aks.dns_prefix
  node_count = local.json_vars.aks.node_count
  vm_size = local.json_vars.aks.vm_size
  os_disk_size_gb = local.json_vars.aks.os_disk_size_gb
  tags = local.json_vars.aks.tags

}