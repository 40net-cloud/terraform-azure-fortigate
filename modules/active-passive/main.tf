##############################################################################################################
#
# FortiGate Active/Passive High Availability with Azure Standard Load Balancer - External and Internal
# Terraform deployment template for Microsoft Azure
#
##############################################################################################################
locals {
  fgt_name         = "${var.prefix}-fgt"
  fgt_a_name       = "${var.prefix}-fgt-a"
  fgt_b_name       = "${var.prefix}-fgt-b"
  fgt_a_customdata = base64encode(templatefile("${path.module}/fgt-customdata.tftpl", var.fgt_a_customdata_variables))
  fgt_b_customdata = base64encode(templatefile("${path.module}/fgt-customdata.tftpl", var.fgt_b_customdata_variables))

  lb_pools_ip_addresses = { for lb_pool in flatten([
    for zonek, zonev in var.fgt_ip_configuration : [
      for fgtk, fgtv in zonev : [
        for ipck, ipcv in fgtv : [
          for lbk, lbv in ipcv.load_balancer_backend_pools : {
            name                    = fgtk
            ip_address              = ipcv.private_ip_address
            backend_address_pool_id = lbv.load_balancer_backend_pool_resource_id
            zone_key                = zonek
            ipconfig_key            = ipck
            lb_key                  = lbk
          }
        ]
      ]
    ]
  ]) : "${lb_pool.name}-${lb_pool.zone_key}-${lb_pool.ipconfig_key}-${lb_pool.lb_key}" => lb_pool }
}

resource "azurerm_availability_set" "fgtavset" {
  count               = var.fgt_availability_set ? 1 : 0
  name                = "${local.fgt_name}-availabilityset"
  location            = var.location
  managed             = true
  resource_group_name = var.resource_group_name
}

resource "azurerm_lb_backend_address_pool_address" "fgtaifcext2elbbackendpool" {
  for_each                = local.lb_pools_ip_addresses
  name                    = each.key
  backend_address_pool_id = each.value.backend_address_pool_id
  virtual_network_id      = var.virtual_network_id
  ip_address              = each.value.ip_address
}

resource "azurerm_network_interface" "fgtaifcext" {
  name                 = "${local.fgt_a_name}-nic1-ext"
  location             = var.location
  resource_group_name  = var.resource_group_name
  ip_forwarding_enabled = true

  dynamic "ip_configuration" {
    for_each = var.fgt_ip_configuration["external"]["fgt-a"]
    content {
      name                                               = ip_configuration.value.name
      private_ip_address_allocation                      = ip_configuration.value.private_ip_address_allocation
      gateway_load_balancer_frontend_ip_configuration_id = ip_configuration.value.gateway_load_balancer_frontend_ip_configuration_resource_id
      primary                                            = ip_configuration.value.is_primary_ipconfiguration
      private_ip_address                                 = ip_configuration.value.private_ip_address
      private_ip_address_version                         = ip_configuration.value.private_ip_address_version
      public_ip_address_id                               = ip_configuration.value.public_ip_address_resource_id
      subnet_id                                          = ip_configuration.value.private_ip_subnet_resource_id
    }
  }
}

resource "azurerm_network_interface_security_group_association" "fgtaifcextnsg" {
  network_interface_id      = azurerm_network_interface.fgtaifcext.id
  network_security_group_id = azurerm_network_security_group.fgtnsg.id
}

resource "azurerm_network_interface" "fgtaifcint" {
  name                 = "${local.fgt_a_name}-nic2-int"
  location             = var.location
  resource_group_name  = var.resource_group_name
  ip_forwarding_enabled = true

  dynamic "ip_configuration" {
    for_each = var.fgt_ip_configuration["internal"]["fgt-a"]
    content {
      name                                               = ip_configuration.value.name
      private_ip_address_allocation                      = ip_configuration.value.private_ip_address_allocation
      gateway_load_balancer_frontend_ip_configuration_id = ip_configuration.value.gateway_load_balancer_frontend_ip_configuration_resource_id
      primary                                            = ip_configuration.value.is_primary_ipconfiguration
      private_ip_address                                 = ip_configuration.value.private_ip_address
      private_ip_address_version                         = ip_configuration.value.private_ip_address_version
      public_ip_address_id                               = ip_configuration.value.public_ip_address_resource_id
      subnet_id                                          = ip_configuration.value.private_ip_subnet_resource_id
    }
  }
}

resource "azurerm_network_interface_security_group_association" "fgtaifcintnsg" {
  network_interface_id      = azurerm_network_interface.fgtaifcint.id
  network_security_group_id = azurerm_network_security_group.fgtnsg.id
}

resource "azurerm_network_interface" "fgtaifchasync" {
  name                 = "${local.fgt_a_name}-nic3-hasync"
  location             = var.location
  resource_group_name  = var.resource_group_name
  ip_forwarding_enabled = true

  dynamic "ip_configuration" {
    for_each = var.fgt_ip_configuration["hasync"]["fgt-a"]
    content {
      name                                               = ip_configuration.value.name
      private_ip_address_allocation                      = ip_configuration.value.private_ip_address_allocation
      gateway_load_balancer_frontend_ip_configuration_id = ip_configuration.value.gateway_load_balancer_frontend_ip_configuration_resource_id
      primary                                            = ip_configuration.value.is_primary_ipconfiguration
      private_ip_address                                 = ip_configuration.value.private_ip_address
      private_ip_address_version                         = ip_configuration.value.private_ip_address_version
      public_ip_address_id                               = ip_configuration.value.public_ip_address_resource_id
      subnet_id                                          = ip_configuration.value.private_ip_subnet_resource_id
    }
  }
}

resource "azurerm_network_interface_security_group_association" "fgtaifchasyncnsg" {
  network_interface_id      = azurerm_network_interface.fgtaifchasync.id
  network_security_group_id = azurerm_network_security_group.fgtnsg.id
}

resource "azurerm_network_interface" "fgtaifchamgmt" {
  name                          = "${local.fgt_a_name}-nic4-mgmt"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  ip_forwarding_enabled          = true
  accelerated_networking_enabled = var.fgt_accelerated_networking

  dynamic "ip_configuration" {
    for_each = var.fgt_ip_configuration["hamgmt"]["fgt-a"]
    content {
      name                                               = ip_configuration.value.name
      private_ip_address_allocation                      = ip_configuration.value.private_ip_address_allocation
      gateway_load_balancer_frontend_ip_configuration_id = ip_configuration.value.gateway_load_balancer_frontend_ip_configuration_resource_id
      primary                                            = ip_configuration.value.is_primary_ipconfiguration
      private_ip_address                                 = ip_configuration.value.private_ip_address
      private_ip_address_version                         = ip_configuration.value.private_ip_address_version
      public_ip_address_id                               = ip_configuration.value.public_ip_address_resource_id
      subnet_id                                          = ip_configuration.value.private_ip_subnet_resource_id
    }
  }
}

resource "azurerm_network_interface_security_group_association" "fgtaifchamgmtnsg" {
  network_interface_id      = azurerm_network_interface.fgtaifchamgmt.id
  network_security_group_id = azurerm_network_security_group.fgtnsg.id
}

resource "azurerm_linux_virtual_machine" "fgtavm" {
  name                  = local.fgt_a_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.fgtaifcext.id, azurerm_network_interface.fgtaifcint.id, azurerm_network_interface.fgtaifchasync.id, azurerm_network_interface.fgtaifchamgmt.id]
  size                  = var.fgt_vmsize
  availability_set_id   = var.fgt_availability_set ? azurerm_availability_set.fgtavset[0].id : null
  zone                  = var.fgt_availability_set ? null : var.fgt_availability_zone[0]

  identity {
    type = "SystemAssigned"
  }

  source_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortigate-vm_v5"
    sku       = var.fgt_image_sku
    version   = var.fgt_version
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet_fortigate-vm_v5"
    name      = var.fgt_image_sku
  }

  os_disk {
    name                 = "${local.fgt_a_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false
  custom_data                     = local.fgt_a_customdata

  dynamic "boot_diagnostics" {
    for_each = var.fgt_serial_console ? [1] : []

    content {
    }
  }

  tags = var.fortinet_tags

  lifecycle {
    ignore_changes = [custom_data]
  }

  depends_on = [ #set explicit depends on for each association to address delete order issues.
    azurerm_network_interface_security_group_association.fgtaifcextnsg,
    azurerm_network_interface_security_group_association.fgtaifcintnsg,
    azurerm_network_interface_security_group_association.fgtaifchasyncnsg,
    azurerm_network_interface_security_group_association.fgtaifchamgmtnsg
  ]
}

resource "azurerm_managed_disk" "fgtavm-datadisk" {
  count                = var.fgt_datadisk_count
  name                 = "${local.fgt_a_name}-datadisk-${count.index}"
  location             = var.location
  zone                 = var.fgt_availability_set ? null : var.fgt_availability_zone[0]
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.fgt_datadisk_size
}

resource "azurerm_virtual_machine_data_disk_attachment" "fgtavm-datadisk-attach" {
  count              = var.fgt_datadisk_count
  managed_disk_id    = element(azurerm_managed_disk.fgtavm-datadisk.*.id, count.index)
  virtual_machine_id = azurerm_linux_virtual_machine.fgtavm.id
  lun                = count.index
  caching            = "ReadWrite"
}

resource "azurerm_network_interface" "fgtbifcext" {
  name                          = "${local.fgt_b_name}-nic1-ext"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  ip_forwarding_enabled          = true
  accelerated_networking_enabled = var.fgt_accelerated_networking

  dynamic "ip_configuration" {
    for_each = var.fgt_ip_configuration["external"]["fgt-b"]
    content {
      name                                               = ip_configuration.value.name
      private_ip_address_allocation                      = ip_configuration.value.private_ip_address_allocation
      gateway_load_balancer_frontend_ip_configuration_id = ip_configuration.value.gateway_load_balancer_frontend_ip_configuration_resource_id
      primary                                            = ip_configuration.value.is_primary_ipconfiguration
      private_ip_address                                 = ip_configuration.value.private_ip_address
      private_ip_address_version                         = ip_configuration.value.private_ip_address_version
      public_ip_address_id                               = ip_configuration.value.public_ip_address_resource_id
      subnet_id                                          = ip_configuration.value.private_ip_subnet_resource_id
    }
  }
}

resource "azurerm_network_interface_security_group_association" "fgtbifcextnsg" {
  network_interface_id      = azurerm_network_interface.fgtbifcext.id
  network_security_group_id = azurerm_network_security_group.fgtnsg.id
}

resource "azurerm_network_interface" "fgtbifcint" {
  name                          = "${local.fgt_b_name}-nic2-int"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  ip_forwarding_enabled          = true
  accelerated_networking_enabled = var.fgt_accelerated_networking

  dynamic "ip_configuration" {
    for_each = var.fgt_ip_configuration["internal"]["fgt-b"]
    content {
      name                                               = ip_configuration.value.name
      private_ip_address_allocation                      = ip_configuration.value.private_ip_address_allocation
      gateway_load_balancer_frontend_ip_configuration_id = ip_configuration.value.gateway_load_balancer_frontend_ip_configuration_resource_id
      primary                                            = ip_configuration.value.is_primary_ipconfiguration
      private_ip_address                                 = ip_configuration.value.private_ip_address
      private_ip_address_version                         = ip_configuration.value.private_ip_address_version
      public_ip_address_id                               = ip_configuration.value.public_ip_address_resource_id
      subnet_id                                          = ip_configuration.value.private_ip_subnet_resource_id
    }
  }
}

resource "azurerm_network_interface_security_group_association" "fgtbifcintnsg" {
  network_interface_id      = azurerm_network_interface.fgtbifcint.id
  network_security_group_id = azurerm_network_security_group.fgtnsg.id
}

resource "azurerm_network_interface" "fgtbifchasync" {
  name                          = "${local.fgt_b_name}-nic3-hasync"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  ip_forwarding_enabled          = true
  accelerated_networking_enabled = var.fgt_accelerated_networking

  dynamic "ip_configuration" {
    for_each = var.fgt_ip_configuration["hasync"]["fgt-b"]
    content {
      name                                               = ip_configuration.value.name
      private_ip_address_allocation                      = ip_configuration.value.private_ip_address_allocation
      gateway_load_balancer_frontend_ip_configuration_id = ip_configuration.value.gateway_load_balancer_frontend_ip_configuration_resource_id
      primary                                            = ip_configuration.value.is_primary_ipconfiguration
      private_ip_address                                 = ip_configuration.value.private_ip_address
      private_ip_address_version                         = ip_configuration.value.private_ip_address_version
      public_ip_address_id                               = ip_configuration.value.public_ip_address_resource_id
      subnet_id                                          = ip_configuration.value.private_ip_subnet_resource_id
    }
  }
}

resource "azurerm_network_interface_security_group_association" "fgtbifchasyncnsg" {
  network_interface_id      = azurerm_network_interface.fgtbifchasync.id
  network_security_group_id = azurerm_network_security_group.fgtnsg.id
}

resource "azurerm_network_interface" "fgtbifchamgmt" {
  name                          = "${local.fgt_b_name}-nic4-mgmt"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  ip_forwarding_enabled          = true
  accelerated_networking_enabled = var.fgt_accelerated_networking

  dynamic "ip_configuration" {
    for_each = var.fgt_ip_configuration["hamgmt"]["fgt-b"]
    content {
      name                                               = ip_configuration.value.name
      private_ip_address_allocation                      = ip_configuration.value.private_ip_address_allocation
      gateway_load_balancer_frontend_ip_configuration_id = ip_configuration.value.gateway_load_balancer_frontend_ip_configuration_resource_id
      primary                                            = ip_configuration.value.is_primary_ipconfiguration
      private_ip_address                                 = ip_configuration.value.private_ip_address
      private_ip_address_version                         = ip_configuration.value.private_ip_address_version
      public_ip_address_id                               = ip_configuration.value.public_ip_address_resource_id
      subnet_id                                          = ip_configuration.value.private_ip_subnet_resource_id
    }
  }
}

resource "azurerm_network_interface_security_group_association" "fgtbifchamgmtnsg" {
  network_interface_id      = azurerm_network_interface.fgtbifchamgmt.id
  network_security_group_id = azurerm_network_security_group.fgtnsg.id
}

resource "azurerm_linux_virtual_machine" "fgtbvm" {
  name                  = local.fgt_b_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.fgtbifcext.id, azurerm_network_interface.fgtbifcint.id, azurerm_network_interface.fgtbifchasync.id, azurerm_network_interface.fgtbifchamgmt.id]
  size                  = var.fgt_vmsize
  availability_set_id   = var.fgt_availability_set ? azurerm_availability_set.fgtavset[0].id : null
  zone                  = var.fgt_availability_set ? null : var.fgt_availability_zone[1]

  identity {
    type = "SystemAssigned"
  }

  source_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortigate-vm_v5"
    sku       = var.fgt_image_sku
    version   = var.fgt_version
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet_fortigate-vm_v5"
    name      = var.fgt_image_sku
  }

  os_disk {
    name                 = "${local.fgt_b_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false
  custom_data                     = local.fgt_b_customdata

  dynamic "boot_diagnostics" {
    for_each = var.fgt_serial_console ? [1] : []

    content {
    }
  }

  tags = var.fortinet_tags

  lifecycle {
    ignore_changes = [custom_data]
  }

  depends_on = [ #set explicit depends on for each association to address delete order issues.
    azurerm_network_interface_security_group_association.fgtbifcextnsg,
    azurerm_network_interface_security_group_association.fgtbifcintnsg,
    azurerm_network_interface_security_group_association.fgtbifchasyncnsg,
    azurerm_network_interface_security_group_association.fgtbifchamgmtnsg
  ]
}

resource "azurerm_managed_disk" "fgtbvm-datadisk" {
  count                = var.fgt_datadisk_count
  name                 = "${local.fgt_b_name}-datadisk-${count.index}"
  location             = var.location
  zone                 = var.fgt_availability_set ? null : var.fgt_availability_zone[1]
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.fgt_datadisk_size
}

resource "azurerm_virtual_machine_data_disk_attachment" "fgtbvm-datadisk-attach" {
  count              = var.fgt_datadisk_count
  managed_disk_id    = element(azurerm_managed_disk.fgtbvm-datadisk.*.id, count.index)
  virtual_machine_id = azurerm_linux_virtual_machine.fgtbvm.id
  lun                = count.index
  caching            = "ReadWrite"
}

##############################################################################################################
