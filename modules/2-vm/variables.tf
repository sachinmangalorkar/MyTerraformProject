variable "application_port" {
   description = "The port that you want to expose to the external load balancer"
   default     = 80
}

variable "location" {
description = "Location where to deploy resources"
}

variable "rg_network" {
description = "Name of the Resource Group where resources will be deployed"
}

variable "public_ip_address_id" {
description = "Public IP ID to frontend the LB"
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