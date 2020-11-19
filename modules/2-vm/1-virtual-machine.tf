provider "azurerm" {
  version = ">= 2.26"
  features {}
}

resource "azurerm_lb" "vmss" {
 name                = "vmss-lb"
 location            = "${var.location}"
 resource_group_name = "${var.rg_network}"

 frontend_ip_configuration {
   name                 = "PublicIPAddress"
   public_ip_address_id = "${var.public_ip_address_id}"
 }

}

resource "azurerm_lb_backend_address_pool" "bpepool" {
 resource_group_name = "${var.rg_network}"
 loadbalancer_id     = azurerm_lb.vmss.id
 name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "vmss" {
 resource_group_name = "${var.rg_network}"
 loadbalancer_id     = azurerm_lb.vmss.id
 name                = "running-probe"
 port                = var.application_port
}

resource "azurerm_lb_rule" "lbrule" {
   resource_group_name            = "${var.rg_network}"
   loadbalancer_id                = azurerm_lb.vmss.id
   name                           = "lbRule01"
   protocol                       = "Tcp"
   frontend_port                  = var.application_port
   backend_port                   = var.application_port
   backend_address_pool_id        = azurerm_lb_backend_address_pool.bpepool.id
   frontend_ip_configuration_name = "PublicIPAddress"
   probe_id                       = azurerm_lb_probe.vmss.id
}

resource "azurerm_virtual_machine_scale_set" "vmss" {
 name                = "vmscaleset"
 location            = "${var.location}"
 resource_group_name = "${var.rg_network}"
 upgrade_policy_mode = "Manual"

 sku {
   name     = "Standard_DS1_v2"
   tier     = "Standard"
   capacity = 2
 }

 storage_profile_image_reference {
   publisher = "Canonical"
   offer     = "UbuntuServer"
   sku       = "16.04-LTS"
   version   = "latest"
 }

 storage_profile_os_disk {
   name              = ""
   caching           = "ReadWrite"
   create_option     = "FromImage"
   managed_disk_type = "Standard_LRS"
 }

 storage_profile_data_disk {
   lun          = 0
   caching        = "ReadWrite"
   create_option  = "Empty"
   disk_size_gb   = 10
 }

 os_profile {
   computer_name_prefix = "vmlab"
   admin_username       = "${var.admin_username}"
   admin_password       = "${var.admin_password}"
   custom_data          = file("web.conf")
 }

 os_profile_linux_config {
   disable_password_authentication = false
 }

 network_profile {
   name    = "terraformnetworkprofile"
   primary = true

   ip_configuration {
     name                                   = "IPConfiguration"
     subnet_id                              = "${var.subnet_id}"
     load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
     primary = true
   }
 }
}

resource "azurerm_monitor_autoscale_setting" "vmss" {
  name                = "myAutoscaleSetting"
  resource_group_name = "${var.rg_network}"
  location            = "${var.location}"
  target_resource_id  = azurerm_virtual_machine_scale_set.vmss.id

  profile {
    name = "defaultAutoScaleProfile"
  
    capacity {
      default = 1
      minimum = 1
      maximum = 5
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}
