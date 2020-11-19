provider "azurerm" {
  version = ">= 2.26"
  features {}
}

//create Resource Group

resource "azurerm_resource_group" "rg_network" {
 name     = var.rg_network
 location = var.location
 
}

// create VNET
module "create_network" {
    source = "./modules/1-network"
    location = azurerm_resource_group.rg_network.location
    rg_network = azurerm_resource_group.rg_network.name
    
}

// Create VMSS

module "create_vmss" {
    source = "./modules/2-vm"
    rg_network = "${azurerm_resource_group.rg_network.name}"
    subnet_id = "${module.create_network.mgmt_sub_id}"
    public_ip_address_id = "${module.create_network.mgmt_pip_id}"
    location = "${azurerm_resource_group.rg_network.location}"
    admin_username = "${var.admin_user}" 
    admin_password = "${var.admin_password}"
    
}
