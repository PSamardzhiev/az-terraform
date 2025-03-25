terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_linux_virtual_machine" "accedia-vm" {
  resource_group_name = var.rg_name
  location = var.location
  name = var.vm_name
  size = var.vm_size
  admin_username = var.admin_username
  admin_password = var.admin_password
  network_interface_ids = [var.network_interface_id]
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = var.publisher
    offer = var.offer
    sku = var.sku
    version = var.vm_version
  }
  admin_ssh_key {
    username = var.admin_ssh_username
    public_key = "${file(var.public_key_path)}"
  }
}