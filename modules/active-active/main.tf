##############################################################################################################
#
# FortiGate Active/Passive High Availability with Azure Standard Load Balancer - External and Internal
# Terraform deployment template for Microsoft Azure
#
##############################################################################################################
locals {
  fgt_name_prefix   = "${var.prefix}-fgt"
  #  fgt_a_customdata = base64encode(templatefile("${path.module}/fgt-customdata.tftpl", var.fgt_a_customdata_variables))
  #  fgt_b_customdata = base64encode(templatefile("${path.module}/fgt-customdata.tftpl", var.fgt_b_customdata_variables))

  #  lb_pools_ip_addresses = { for lb_pool in flatten([
  #    for zonek, zonev in var.fgt_ip_configuration : [
  #      for fgtk, fgtv in zonev : [
  #        for ipck, ipcv in fgtv : [
  #          for lbk, lbv in ipcv.load_balancer_backend_pools : {
  #            name                    = fgtk
  #            ip_address              = ipcv.private_ip_address
  #            backend_address_pool_id = lbv.load_balancer_backend_pool_resource_id
  #            zone_key                = zonek
  #            ipconfig_key            = ipck
  #            lb_key                  = lbk
  #          }
  #        ]
  #      ]
  #    ]
  #  ]) : "${lb_pool.name}-${lb_pool.zone_key}-${lb_pool.ipconfig_key}-${lb_pool.lb_key}" => lb_pool }
  vm_datadiskdisk_count_map = { for k, query in var.fgt_list : k => var.fgt_datadisk_count }
  luns                      = { for k in local.datadisk_lun_map : k.datadisk_name => k.lun }
  datadisk_lun_map = flatten([
    for vm_name, count in local.vm_datadiskdisk_count_map : [
      for i in range(count) : {
        datadisk_name = format("%s-%s-datadisk_%02d", var.prefix, vm_name, i)
        lun           = i
      }
    ]
  ])
}

resource "azurerm_availability_set" "fgtavset" {
  count               = var.fgt_availability_set ? 1 : 0
  name                = format("%s-availabilityset", var.prefix)
  location            = var.location
  managed             = true
  resource_group_name = var.resource_group_name
}

#resource "azurerm_lb_backend_address_pool_address" "fgtaifcext2elbbackendpool" {
#  for_each                = local.lb_pools_ip_addresses
#  name                    = each.key
#  backend_address_pool_id = each.value.backend_address_pool_id
#  virtual_network_id      = var.virtual_network_id
#  ip_address              = each.value.ip_address
#}

resource "azurerm_network_interface" "fgtifcext" {
  for_each            = var.fgt_list
  name                 = format("%s-nic1-ext", each.value.hostname)
  location             = var.location
  resource_group_name  = var.resource_group_name
  ip_forwarding_enabled = true

  dynamic "ip_configuration" {
    for_each = var.fgt_ip_configuration["external"]
    content {
      name                                               = ip_configuration.value.name
      private_ip_address_allocation                      = ip_configuration.value.private_ip_address_allocation
      gateway_load_balancer_frontend_ip_configuration_id = ip_configuration.value.gateway_load_balancer_frontend_ip_configuration_resource_id
      primary                                            = ip_configuration.value.is_primary_ipconfiguration
      private_ip_address                                 = ip_configuration.value.private_ip_addresses == null ? null : ip_configuration.value.private_ip_addresses[count.index]
      private_ip_address_version                         = ip_configuration.value.private_ip_address_version
      public_ip_address_id                               = ip_configuration.value.public_ip_address_resource_ids == null ? null : ip_configuration.value.public_ip_address_resource_ids[count.index]
      subnet_id                                          = ip_configuration.value.private_ip_subnet_resource_id
    }
  }
}

resource "azurerm_network_interface_security_group_association" "fgtaifcextnsg" {
  for_each                     = var.fgt_list
  network_interface_id      = azurerm_network_interface.fgtifcext[each.key].id
  network_security_group_id = azurerm_network_security_group.fgtnsg.id
}

resource "azurerm_network_interface" "fgtifcint" {
  for_each            = var.fgt_list
  name                 = format("%s-nic1-int", each.value.hostname)
  location             = var.location
  resource_group_name  = var.resource_group_name
  ip_forwarding_enabled = true

  dynamic "ip_configuration" {
    for_each = var.fgt_ip_configuration["internal"]
    content {
      name                                               = ip_configuration.value.name
      private_ip_address_allocation                      = ip_configuration.value.private_ip_address_allocation
      gateway_load_balancer_frontend_ip_configuration_id = ip_configuration.value.gateway_load_balancer_frontend_ip_configuration_resource_id
      primary                                            = ip_configuration.value.is_primary_ipconfiguration
      private_ip_address                                 = ip_configuration.value.private_ip_addresses == null ? null : ip_configuration.value.private_ip_addresses[count.index]
      private_ip_address_version                         = ip_configuration.value.private_ip_address_version
      public_ip_address_id                               = ip_configuration.value.public_ip_address_resource_ids == null ? null : ip_configuration.value.public_ip_address_resource_ids[count.index]
      subnet_id                                          = ip_configuration.value.private_ip_subnet_resource_id
    }
  }
}

resource "azurerm_network_interface_security_group_association" "fgtaifcintnsg" {
  for_each                     = var.fgt_list
  network_interface_id      = azurerm_network_interface.fgtifcext[each.key].id
  network_security_group_id = azurerm_network_security_group.fgtnsg.id
}

resource "azurerm_linux_virtual_machine" "fgtvm" {
  for_each              = var.fgt_list
  name                  = each.value.hostname
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.fgtifcext[each.key].id, azurerm_network_interface.fgtifcint[each.key].id]
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
    name                 = "${local.fgt_name_prefix}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false
  #  custom_data                     = local.fgt_a_customdata

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
    azurerm_network_interface_security_group_association.fgtaifcintnsg
  ]
}

resource "azurerm_managed_disk" "managed_disk" {
  for_each             = toset([for j in local.datadisk_lun_map : j.datadisk_name])
  name                 = each.key
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.fgt_datadisk_size
}

resource "azurerm_virtual_machine_data_disk_attachment" "managed_disk_attach" {
  for_each           = toset([for j in local.datadisk_lun_map : j.datadisk_name])
  managed_disk_id    = azurerm_managed_disk.managed_disk[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.fgtvm[element(split("_", each.key), 1)].id
  lun                = lookup(local.luns, each.key)
  caching            = "ReadWrite"
}

#resource "azurerm_managed_disk" "fgtavm-datadisk" {
#  count                = var.fgt_datadisk_count
#  name                 = "${local.fgt_a_name}-datadisk-${count.index}"
#  location             = var.location
#  zone                 = var.fgt_availability_set ? null : var.fgt_availability_zone[0]
#  resource_group_name  = var.resource_group_name
#  storage_account_type = "Standard_LRS"
#  create_option        = "Empty"
#  disk_size_gb         = var.fgt_datadisk_size
#}

#resource "azurerm_virtual_machine_data_disk_attachment" "fgtavm-datadisk-attach" {
#  count              = var.fgt_datadisk_count
#  managed_disk_id    = element(azurerm_managed_disk.fgtavm-datadisk.*.id, count.index)
#  virtual_machine_id = azurerm_linux_virtual_machine.fgtavm.id
#  lun                = count.index
#  caching            = "ReadWrite"
#}

##############################################################################################################
