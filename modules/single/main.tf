##############################################################################################################
#
# FortiGate a standalone FortiGate VM
# Terraform deployment template for Microsoft Azure
#
##############################################################################################################
locals {
  fgt_name              = "${var.prefix***REMOVED***-fgt"
  fgt_external_ipaddr = cidrhost(data.azurerm_subnet.subnet1.address_prefixes[0], 5)
  fgt_internal_ipaddr = cidrhost(data.azurerm_subnet.subnet2.address_prefixes[0], 5)
  fgt_vars = {
    fgt_vm_name                = "${local.fgt_name***REMOVED***"
    fgt_license_file           = var.fgt_byol_license_file
    fgt_license_fortiflex      = var.fgt_byol_fortiflex_license_token
    fgt_username               = var.username
    fgt_ssh_public_key         = var.fgt_ssh_public_key_file
    fgt_external_ipaddr        = local.fgt_external_ipaddr
    fgt_external_mask          = cidrnetmask(data.azurerm_subnet.subnet1.address_prefixes[0])
    fgt_external_gw            = cidrhost(data.azurerm_subnet.subnet1.address_prefixes[0], 1)
    fgt_internal_ipaddr        = local.fgt_internal_ipaddr
    fgt_internal_mask          = tostring(cidrnetmask(data.azurerm_subnet.subnet2.address_prefixes[0]))
    fgt_internal_gw            = tostring(cidrhost(data.azurerm_subnet.subnet2.address_prefixes[0], 1))
    vnet_network               = data.azurerm_virtual_network.vnet.address_space[0]
    fgt_additional_custom_data = var.fgt_additional_custom_data
    fgt_fortimanager_ip        = var.fgt_fortimanager_ip
    fgt_fortimanager_serial    = var.fgt_fortimanager_serial

  ***REMOVED***
  fgt_customdata = base64encode(templatefile("${path.module***REMOVED***/fgt-customdata.tftpl", local.fgt_vars))
***REMOVED***

resource "azurerm_public_ip" "fgtpip" {
  name                = "${local.fgt_name***REMOVED***-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = format("%s-%s", lower(local.fgt_name), "pip")
***REMOVED***

resource "azurerm_network_interface" "fgtifcext" {
  name                 = "${local.fgt_name***REMOVED***-nic1-ext"
  location             = var.location
  resource_group_name  = var.resource_group_name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "interface1"
    subnet_id                     = data.azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt_external_ipaddr
    public_ip_address_id          = azurerm_public_ip.fgtpip.id
  ***REMOVED***
***REMOVED***

resource "azurerm_network_interface_security_group_association" "fgtifcextnsg" {
  network_interface_id      = azurerm_network_interface.fgtifcext.id
  network_security_group_id = azurerm_network_security_group.fgtnsg.id
***REMOVED***

resource "azurerm_network_interface" "fgtifcint" {
  name                 = "${local.fgt_name***REMOVED***-nic2-int"
  location             = var.location
  resource_group_name  = var.resource_group_name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "interface1"
    subnet_id                     = data.azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt_internal_ipaddr
  ***REMOVED***
***REMOVED***

resource "azurerm_network_interface_security_group_association" "fgtifcintnsg" {
  network_interface_id      = azurerm_network_interface.fgtifcint.id
  network_security_group_id = azurerm_network_security_group.fgtnsg.id
***REMOVED***

resource "azurerm_linux_virtual_machine" "fgtvm" {
  name                  = local.fgt_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.fgtifcext.id, azurerm_network_interface.fgtifcint.id]
  size                  = var.fgt_vmsize

  identity {
    type = "SystemAssigned"
  ***REMOVED***

  source_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortigate-vm_v5"
    sku       = var.fgt_image_sku
    version   = var.fgt_version
  ***REMOVED***

  plan {
    publisher = "fortinet"
    product   = "fortinet_fortigate-vm_v5"
    name      = var.fgt_image_sku
  ***REMOVED***

  os_disk {
    name                 = "${local.fgt_name***REMOVED***-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  ***REMOVED***

  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false
  custom_data                     = local.fgt_customdata

  dynamic "boot_diagnostics" {
    for_each = var.fgt_serial_console ? [1] : []

    content {
    ***REMOVED***
  ***REMOVED***

  tags = var.fortinet_tags

  lifecycle {
    ignore_changes = [custom_data]
  ***REMOVED***
***REMOVED***

#resource "azurerm_managed_disk" "fgtvm-datadisk" {
#  name                 = "${local.fgt_name***REMOVED***-datadisk"
#  location             = var.location
#  resource_group_name  = var.resource_group_name
#  storage_account_type = "Standard_LRS"
#  create_option        = "Empty"
#  disk_size_gb         = 50
#***REMOVED***
#
#resource "azurerm_virtual_machine_data_disk_attachment" "fgtvm-datadisk-attach" {
#  managed_disk_id    = azurerm_managed_disk.fgtvm-datadisk.id
#  virtual_machine_id = azurerm_linux_virtual_machine.fgtvm.id
#  lun                = 0
#  caching            = "ReadWrite"
#***REMOVED***

##############################################################################################################
