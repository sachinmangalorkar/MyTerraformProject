provider "azurerm" {
  version = ">= 2.26"
  features {}
}

resource "azurerm_network_interface" "db_nic"{
    name = "db-nic01"
    location = "${var.location}"
    resource_group_name = "${var.rg_network}"

    ip_configuration{
        name = "ipconfig"
        subnet_id = "${var.subnet_id}"
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_virtual_machine" "db_vm"{

    name = "dbvm01"
    location = "${var.location}"
    resource_group_name = "${var.rg_network}"
    network_interface_ids = ["${azurerm_network_interface.db_nic.id}"]
    vm_size = "Standard_DS1_v2"
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true

    storage_image_reference{

      publisher = "MicrosoftSQLServer"
      offer = "SQL2016SP2-WS2016"
      sku = "SQLDEV"
      version = "latest"
    }
        
   

    storage_os_disk {
 
        name = "DB-OSdisk"
        caching = "ReadWrite"
        create_option = "FromImage"
        managed_disk_type = "Standard_LRS"
        }

    os_profile {
        computer_name = "dbvm01"
        admin_username = "${var.admin_username}"
        admin_password = "${var.admin_password}"
 
        }
    os_profile_windows_config {
        provision_vm_agent = "true"
        }

}

