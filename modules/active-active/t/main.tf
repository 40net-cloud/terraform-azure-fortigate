# set locals for multi data disks
locals {
  vm_datadiskdisk_count_map = { for k, query in var.vm_list : k => var.disks_per_instance ***REMOVED***
  luns                      = { for k in local.datadisk_lun_map : k.datadisk_name => k.lun ***REMOVED***
  datadisk_lun_map = flatten([
    for vm_name, count in local.vm_datadiskdisk_count_map : [
      for i in range(count) : {
        datadisk_name = format("%s-datadisk_%s_disk%02d", var.prefix, vm_name, i)
        lun           = i
      ***REMOVED***
    ]
  ])
***REMOVED***

# create resource group
resource "azurerm_resource_group" "resource_group" {
  name     = format("%s-rg", var.prefix)
  location = var.location
***REMOVED***

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix***REMOVED***-vnet"
  address_space       = var.vnet
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
***REMOVED***

resource "azurerm_subnet" "subnets" {
  for_each = { for s in var.subnets : s.name => s ***REMOVED***

  name                 = each.key
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.cidr
***REMOVED***


# create data disk(s)
resource "azurerm_managed_disk" "managed_disk" {
  for_each             = toset([for j in local.datadisk_lun_map : j.datadisk_name])
  name                 = each.key
  location             = azurerm_resource_group.resource_group.location
  resource_group_name  = azurerm_resource_group.resource_group.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size_gb
***REMOVED***

# create availability set
resource "azurerm_availability_set" "vm_availability_set" {
  name                = format("%s-availability-set", var.prefix)
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
***REMOVED***

# create Security Group to access linux
resource "azurerm_network_security_group" "linux_vm_nsg" {
  name                = format("%s-linux-vm-nsg", var.prefix)
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  security_rule {
    name                       = "AllowSSH"
    description                = "Allow SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  ***REMOVED***
***REMOVED***

# associate the linux NSG with the subnet
resource "azurerm_subnet_network_security_group_association" "linux_vm_nsg_association" {
  subnet_id                 = azurerm_subnet.subnets["subnet-external"].id
  network_security_group_id = azurerm_network_security_group.linux_vm_nsg.id
***REMOVED***

# create NICs for vms
resource "azurerm_network_interface" "nics" {
  depends_on          = [azurerm_subnet_network_security_group_association.linux_vm_nsg_association]
  for_each            = var.vm_list
  name                = "${each.value.hostname***REMOVED***-nic"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  ip_configuration {
    name                          = format("%s-proxy-ip", var.prefix)
    subnet_id                     = azurerm_subnet.subnets["subnet-external"].id
    private_ip_address_allocation = "Dynamic"
  ***REMOVED***
***REMOVED***

# create VMs
resource "azurerm_linux_virtual_machine" "vms" {
  for_each              = var.vm_list
  name                  = each.value.hostname
  location              = azurerm_resource_group.resource_group.location
  resource_group_name   = azurerm_resource_group.resource_group.name
  network_interface_ids = [azurerm_network_interface.nics[each.key].id]
  availability_set_id   = azurerm_availability_set.vm_availability_set.id
  size                  = var.vm_size

  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  os_disk {
    name                 = "${each.value.hostname***REMOVED***-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  ***REMOVED***
  identity {
    type = "SystemAssigned"
  ***REMOVED***
  source_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortigate-vm_v5"
    sku       = "fortinet_fg-vm"
    version   = "7.4.4"
  ***REMOVED***
  plan {
    publisher = "fortinet"
    product   = "fortinet_fortigate-vm_v5"
    name      = "fortinet_fg-vm"
  ***REMOVED***
  dynamic "boot_diagnostics" {
    for_each = var.fgt_serial_console ? [1] : []

    content {
    ***REMOVED***
  ***REMOVED***
***REMOVED***

# attache data disks vms
resource "azurerm_virtual_machine_data_disk_attachment" "managed_disk_attach" {
  for_each           = toset([for j in local.datadisk_lun_map : j.datadisk_name])
  managed_disk_id    = azurerm_managed_disk.managed_disk[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.vms[element(split("_", each.key), 1)].id
  lun                = lookup(local.luns, each.key)
  caching            = "ReadWrite"
***REMOVED***