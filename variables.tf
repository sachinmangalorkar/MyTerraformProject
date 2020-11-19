variable "location" {
 description = "The location where resources will be created"
 default = "East US"
}

variable "rg_network" {
 description = "The name of the resource group in which the resources will be created"
 default     = "Project04RG"
}

variable "admin_user" {
   description = "User name to use as the admin account on the VMs that will be part of the VM Scale Set"
   default     = "azureuser"
}

variable "admin_password" {
   description = "Default password for admin account"
   default = "Sp1jk3R!@12#"
}