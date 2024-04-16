##############################################################################################################
#
# FortiGate Active/Passive High Availability with Azure Standard Load Balancer - External and Internal
# Terraform deployment template for Microsoft Azure
#
##############################################################################################################
locals {
  fgt_name              = "${var.prefix}-fgt"
  fgt_a_name            = "${var.prefix}-fgt-a"
  fgt_b_name            = "${var.prefix}-fgt-b"
  fgt_a_external_ipaddr = cidrhost(data.azurerm_subnet.subnet1.address_prefixes[0], 5)
  fgt_a_internal_ipaddr = cidrhost(data.azurerm_subnet.subnet2.address_prefixes[0], 5)
  fgt_a_hasync_ipaddr   = cidrhost(data.azurerm_subnet.subnet3.address_prefixes[0], 5)
  fgt_a_mgmt_ipaddr     = cidrhost(data.azurerm_subnet.subnet4.address_prefixes[0], 5)
  fgt_b_external_ipaddr = cidrhost(data.azurerm_subnet.subnet1.address_prefixes[0], 6)
  fgt_b_internal_ipaddr = cidrhost(data.azurerm_subnet.subnet2.address_prefixes[0], 6)
  fgt_b_hasync_ipaddr   = cidrhost(data.azurerm_subnet.subnet3.address_prefixes[0], 6)
  fgt_b_mgmt_ipaddr     = cidrhost(data.azurerm_subnet.subnet4.address_prefixes[0], 6)
  fgt_a_vars = {
    fgt_vm_name                = "${local.fgt_a_name}"
    fgt_license_file           = var.fgt_byol_license_file_a
    fgt_license_fortiflex      = var.fgt_byol_fortiflex_license_token_a
    fgt_username               = var.username
    fgt_ssh_public_key         = var.fgt_ssh_public_key_file
    fgt_config_ha              = var.fgt_config_ha
    fgt_external_ipaddr        = local.fgt_a_external_ipaddr
    fgt_external_mask          = cidrnetmask(data.azurerm_subnet.subnet1.address_prefixes[0])
    fgt_external_gw            = cidrhost(data.azurerm_subnet.subnet1.address_prefixes[0], 1)
    fgt_internal_ipaddr        = local.fgt_a_internal_ipaddr
    fgt_internal_mask          = tostring(cidrnetmask(data.azurerm_subnet.subnet2.address_prefixes[0]))
    fgt_internal_gw            = tostring(cidrhost(data.azurerm_subnet.subnet2.address_prefixes[0], 1))
    fgt_hasync_ipaddr          = local.fgt_a_hasync_ipaddr
    fgt_hasync_mask            = tostring(cidrnetmask(data.azurerm_subnet.subnet3.address_prefixes[0]))
    fgt_hasync_gw              = tostring(cidrhost(data.azurerm_subnet.subnet3.address_prefixes[0], 1))
    fgt_mgmt_ipaddr            = local.fgt_a_mgmt_ipaddr
    fgt_mgmt_mask              = tostring(cidrnetmask(data.azurerm_subnet.subnet4.address_prefixes[0]))
    fgt_mgmt_gw                = tostring(cidrhost(data.azurerm_subnet.subnet4.address_prefixes[0], 1))
    fgt_ha_peerip              = local.fgt_b_hasync_ipaddr
    fgt_ha_priority            = "255"
    vnet_network               = data.azurerm_virtual_network.vnet.address_space[0]
    fgt_additional_custom_data = var.fgt_additional_custom_data
    fgt_fortimanager_ip        = var.fgt_fortimanager_ip
    fgt_fortimanager_serial    = var.fgt_fortimanager_serial
  }
  fgt_a_customdata = base64encode(templatefile("${path.module}/fgt-customdata.tftpl", local.fgt_a_vars))
  fgt_b_vars = {
    fgt_vm_name                = "${local.fgt_b_name}"
    fgt_license_file           = var.fgt_byol_license_file_b
    fgt_license_fortiflex      = var.fgt_byol_fortiflex_license_token_b
    fgt_username               = var.username
    fgt_ssh_public_key         = var.fgt_ssh_public_key_file
    fgt_config_ha              = var.fgt_config_ha
    fgt_external_ipaddr        = local.fgt_b_external_ipaddr
    fgt_external_mask          = cidrnetmask(data.azurerm_subnet.subnet1.address_prefixes[0])
    fgt_external_gw            = cidrhost(data.azurerm_subnet.subnet1.address_prefixes[0], 1)
    fgt_internal_ipaddr        = local.fgt_b_internal_ipaddr
    fgt_internal_mask          = cidrnetmask(data.azurerm_subnet.subnet2.address_prefixes[0])
    fgt_internal_gw            = cidrhost(data.azurerm_subnet.subnet2.address_prefixes[0], 1)
    fgt_hasync_ipaddr          = local.fgt_b_hasync_ipaddr
    fgt_hasync_mask            = cidrnetmask(data.azurerm_subnet.subnet3.address_prefixes[0])
    fgt_hasync_gw              = cidrhost(data.azurerm_subnet.subnet3.address_prefixes[0], 1)
    fgt_mgmt_ipaddr            = local.fgt_b_mgmt_ipaddr
    fgt_mgmt_mask              = cidrnetmask(data.azurerm_subnet.subnet4.address_prefixes[0])
    fgt_mgmt_gw                = cidrhost(data.azurerm_subnet.subnet4.address_prefixes[0], 1)
    fgt_ha_peerip              = local.fgt_a_hasync_ipaddr
    fgt_ha_priority            = "1"
    vnet_network               = data.azurerm_virtual_network.vnet.address_space[0]
    fgt_additional_custom_data = var.fgt_additional_custom_data
    fgt_fortimanager_ip        = var.fgt_fortimanager_ip
    fgt_fortimanager_serial    = var.fgt_fortimanager_serial
  }
  fgt_b_customdata = base64encode(templatefile("${path.module}/fgt-customdata.tftpl", local.fgt_b_vars))
}

resource "azurerm_availability_set" "fgtavset" {
  name                = "${local.fgt_name}-availabilityset"
  location            = var.location
  managed             = true
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_interface" "fgtaifcext" {
  name                 = "${local.fgt_a_name}-nic1-ext"
  location             = var.location
  resource_group_name  = var.resource_group_name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "interface1"
    subnet_id                     = data.azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt_a_external_ipaddr
  }
}

resource "azurerm_network_interface_security_group_association" "fgtaifcextnsg" {
  network_interface_id      = azurerm_network_interface.fgtaifcext.id
  network_security_group_id = azurerm_network_security_group.fgtnsg.id
}

resource "azurerm_lb_backend_address_pool_address" "fgtaifcext2elbbackendpool" {
  count                   = var.external_loadbalancer_name == "" ? 0 : 1
  name                    = "${var.prefix}-fgtaifcext2elbbackendpool"
  backend_address_pool_id = data.azurerm_lb_backend_address_pool.elb_backend[count.index].id
  virtual_network_id      = data.azurerm_virtual_network.vnet.id
  ip_address              = local.fgt_a_external_ipaddr
}

resource "azurerm_network_interface" "fgtaifcint" {
  name                 = "${local.fgt_a_name}-nic2-int"
  location             = var.location
  resource_group_name  = var.resource_group_name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "interface1"
    subnet_id                     = data.azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt_a_internal_ipaddr
  }
}

resource "azurerm_network_interface_security_group_association" "fgtaifcintnsg" {
  network_interface_id      = azurerm_network_interface.fgtaifcint.id
  network_security_group_id = azurerm_network_security_group.fgtnsg.id
}

resource "azurerm_network_interface_backend_address_pool_association" "fgtaifcint2elbbackendpool" {
  count                   = var.internal_loadbalancer_name == "" ? 0 : 1
  network_interface_id    = azurerm_network_interface.fgtaifcint.id
  ip_configuration_name   = azurerm_network_interface.fgtaifcint.ip_configuration[0].name
  backend_address_pool_id = data.azurerm_lb_backend_address_pool.ilb_backend[count.index].id
}

resource "azurerm_network_interface" "fgtaifchasync" {
  name                 = "${local.fgt_a_name}-nic3-hasync"
  location             = var.location
  resource_group_name  = var.resource_group_name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "interface1"
    subnet_id                     = data.azurerm_subnet.subnet3.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt_a_hasync_ipaddr
  }
}

resource "azurerm_network_interface_security_group_association" "fgtaifchasyncnsg" {
  network_interface_id      = azurerm_network_interface.fgtaifchasync.id
  network_security_group_id = azurerm_network_security_group.fgtnsg.id
}

resource "azurerm_public_ip" "fgtamgmtpip" {
  name                = "${local.fgt_a_name}-mgmt-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = format("%s-%s", lower(local.fgt_a_name), "mgmt-pip")
}

resource "azurerm_network_interface" "fgtaifcmgmt" {
  name                          = "${local.fgt_a_name}-nic4-mgmt"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.fgt_accelerated_networking

  ip_configuration {
    name                          = "interface1"
    subnet_id                     = data.azurerm_subnet.subnet4.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt_a_mgmt_ipaddr
    public_ip_address_id          = azurerm_public_ip.fgtamgmtpip.id
  }
}

resource "azurerm_network_interface_security_group_association" "fgtaifcmgmtnsg" {
  network_interface_id      = azurerm_network_interface.fgtaifcmgmt.id
  network_security_group_id = azurerm_network_security_group.fgtnsg.id
}

resource "azurerm_linux_virtual_machine" "fgtavm" {
  name                  = local.fgt_a_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.fgtaifcext.id, azurerm_network_interface.fgtaifcint.id, azurerm_network_interface.fgtaifchasync.id, azurerm_network_interface.fgtaifcmgmt.id]
  size                  = var.fgt_vmsize
  availability_set_id   = azurerm_availability_set.fgtavset.id

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
}

resource "azurerm_managed_disk" "fgtavm-datadisk" {
  count                = var.fgt_datadisk_count
  name                 = "${local.fgt_a_name}-datadisk-${count.index}"
  location             = var.location
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
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.fgt_accelerated_networking

  ip_configuration {
    name                          = "interface1"
    subnet_id                     = data.azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt_b_external_ipaddr
  }
}

resource "azurerm_network_interface_security_group_association" "fgtbifcextnsg" {
  network_interface_id      = azurerm_network_interface.fgtbifcext.id
  network_security_group_id = azurerm_network_security_group.fgtnsg.id
}

resource "azurerm_network_interface_backend_address_pool_address" "fgtbifcext2elbbackendpool" {
  count                   = var.external_loadbalancer_name == "" ? 0 : 1
  name                    = "${var.prefix}-fgtbifcext2elbbackendpool"
  backend_address_pool_id = data.azurerm_lb_backend_address_pool.elb_backend[count.index].id
  virtual_network_id      = data.azurerm_virtual_network.vnet.id
  ip_address              = local.fgt_b_external_ipaddr
}

resource "azurerm_network_interface" "fgtbifcint" {
  name                          = "${local.fgt_b_name}-nic2-int"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.fgt_accelerated_networking

  ip_configuration {
    name                          = "interface1"
    subnet_id                     = data.azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt_b_internal_ipaddr
  }
}

resource "azurerm_network_interface_security_group_association" "fgtbifcintnsg" {
  network_interface_id      = azurerm_network_interface.fgtbifcint.id
  network_security_group_id = azurerm_network_security_group.fgtnsg.id
}

resource "azurerm_network_interface_backend_address_pool_association" "fgtbifcint2ilbbackendpool" {
  count                   = var.internal_loadbalancer_name == "" ? 0 : 1
  network_interface_id    = azurerm_network_interface.fgtbifcint.id
  ip_configuration_name   = azurerm_network_interface.fgtbifcint.ip_configuration[0].name
  backend_address_pool_id = data.azurerm_lb_backend_address_pool.ilb_backend[count.index].id
}

resource "azurerm_network_interface" "fgtbifchasync" {
  name                          = "${local.fgt_b_name}-nic3-hasync"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.fgt_accelerated_networking

  ip_configuration {
    name                          = "interface1"
    subnet_id                     = data.azurerm_subnet.subnet3.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt_b_hasync_ipaddr
  }
}

resource "azurerm_network_interface_security_group_association" "fgtbifchasyncnsg" {
  network_interface_id      = azurerm_network_interface.fgtbifchasync.id
  network_security_group_id = azurerm_network_security_group.fgtnsg.id
}

resource "azurerm_public_ip" "fgtbmgmtpip" {
  name                = "${local.fgt_b_name}-mgmt-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = format("%s-%s", lower(local.fgt_b_name), "mgmt-pip")
}

resource "azurerm_network_interface" "fgtbifcmgmt" {
  name                          = "${local.fgt_b_name}-nic4-mgmt"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.fgt_accelerated_networking

  ip_configuration {
    name                          = "interface1"
    subnet_id                     = data.azurerm_subnet.subnet4.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt_b_mgmt_ipaddr
    public_ip_address_id          = azurerm_public_ip.fgtbmgmtpip.id
  }
}

resource "azurerm_network_interface_security_group_association" "fgtbifcmgmtnsg" {
  network_interface_id      = azurerm_network_interface.fgtbifcmgmt.id
  network_security_group_id = azurerm_network_security_group.fgtnsg.id
}

resource "azurerm_linux_virtual_machine" "fgtbvm" {
  name                  = local.fgt_b_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.fgtbifcext.id, azurerm_network_interface.fgtbifcint.id, azurerm_network_interface.fgtbifchasync.id, azurerm_network_interface.fgtbifcmgmt.id]
  size                  = var.fgt_vmsize
  availability_set_id   = azurerm_availability_set.fgtavset.id

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
}

resource "azurerm_managed_disk" "fgtbvm-datadisk" {
  count                = var.fgt_datadisk_count
  name                 = "${local.fgt_b_name}-datadisk-${count.index}"
  location             = var.location
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
