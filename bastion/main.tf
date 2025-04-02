resource "azurerm_bastion_host" "accedia-bastion" {
    name = var.bastion_name
    location = var.location
    resource_group_name = var.rg_name
    ip_configuration {
        name = "configuration"
        subnet_id = var.subnet_id
        public_ip_address_id = var.public_ip_address_id
    }
    sku = var.bastion_sku
}