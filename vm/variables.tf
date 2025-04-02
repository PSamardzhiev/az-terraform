variable "rg_name" {}
variable "location" {}
variable "vm_name" {}
variable "vm_size" {}
variable "publisher" {}
variable "vm_version" {}
variable "offer" {}
variable "sku" {}
variable "admin_username" {}
variable "admin_password" {}
variable "admin_ssh_username" {}
variable "public_key_path" {}
variable "network_interface_id" {
    type = string
  
}