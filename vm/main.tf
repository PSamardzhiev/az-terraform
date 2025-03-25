terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.0.0"
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
  connection {
    host = self.public_ip_address
    type = "ssh"
    user = var.admin_ssh_username
    private_key = file("~/.ssh/id_rsa")
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash",
      "curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl",
      "chmod +x kubectl",
      "sudo mv kubectl /usr/local/bin/kubectl",
    ]
  }
}