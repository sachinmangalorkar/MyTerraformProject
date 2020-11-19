provider "azurerm" {
  version = ">= 2.26"
  features {}
}

resource "azurerm_virtual_network" "mgmt_vnet" {
 name                = "vmss-vnet"
 address_space       = ["172.60.0.0/16"]
 location            = "${var.location}"
 resource_group_name = "${var.rg_network}"
 
}

resource "azurerm_subnet" "mgmt_sub_db" {
 name                 = "vmss-subnet01"
 resource_group_name  = "${var.rg_network}"
 virtual_network_name = azurerm_virtual_network.mgmt_vnet.name
 address_prefix       = "172.60.1.0/24"
}

resource "azurerm_subnet" "mgmt_sub_db2" {
 name                 = "vmss-subnet02"
 resource_group_name  = "${var.rg_network}"
 virtual_network_name = azurerm_virtual_network.mgmt_vnet.name
 address_prefix       = "172.60.2.0/24"
}

resource "azurerm_public_ip" "mgmt_pip" {
 name                         = "vmss-public-ip"
 location                     = var.location
 resource_group_name          = "${var.rg_network}"
 allocation_method            = "Static"
 domain_name_label            = random_string.fqdn.result
 
}

resource "random_string" "fqdn" {
 length  = 4
 special = false
 upper   = false
 number  = false
}

output "mgmt_sub_id"{
    value = "${azurerm_subnet.mgmt_sub_db.id}"
}
output "mgmt_sub_id2"{
    value = "${azurerm_subnet.mgmt_sub_db2.id}"
}
output "mgmt_pip_id"{
    value = "${azurerm_public_ip.mgmt_pip.id}"
}
