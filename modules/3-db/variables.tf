
variable "location" {
description = "Location where to deploy resources"
}

variable "rg_network" {
description = "Name of the Resource Group where resources will be deployed"
}

variable "subnet_id" {
description = "Subnet Id where to join the VM"
}

variable "admin_username" {
description = "The username associated with the local administrator account on the virtual machine"
}

variable "admin_password" {
description = "The password associated with the local administrator account on the virtual machine"
}