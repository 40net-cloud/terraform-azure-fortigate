##############################################################################################################
#
# FortiGate a standalone FortiGate VM
# Terraform deployment template for Microsoft Azure
#
##############################################################################################################

# Prefix for all resources created for this deployment in Microsoft Azure
variable "prefix" {
  description = "Added name to each deployed resource"
***REMOVED***

variable "location" {
  description = "Azure region"
***REMOVED***

variable "username" {
***REMOVED***

variable "password" {
***REMOVED***

##############################################################################################################
# FortiGate
##############################################################################################################

variable "fgt_image_sku" {
  description = "Azure Marketplace default image sku hourly (PAYG 'fortinet_fg-vm_payg_2023') or byol (Bring your own license 'fortinet_fg-vm')"
  #  default     = "fortinet_fg-vm_payg_2023"
  default = "fortinet_fg-vm"
***REMOVED***

variable "fgt_version" {
  description = "FortiGate version by default the 'latest' available version in the Azure Marketplace is selected"
  default     = "7.2.8"
***REMOVED***

variable "fgt_byol_license_file" {
  default = ""
***REMOVED***

variable "fgt_byol_fortiflex_license_token" {
  default = ""
***REMOVED***

variable "fgt_ssh_public_key_file" {
  default = ""
***REMOVED***

variable "fgt_accelerated_networking" {
  description = "Enables Accelerated Networking for the network interfaces of the FortiGate"
  default     = "true"
***REMOVED***

variable "fgt_fortimanager_ip" {
  description = "FortiManager Central Management IP address"
  default     = ""
***REMOVED***

variable "fgt_fortimanager_serial" {
  description = "FortiManager Central Management serial number for registration"
  default     = ""
***REMOVED***

variable "fgt_additional_custom_data" {
  description = "Additional FortiGate configuration that will be loaded after the default configuration to setup this architecture."
  default     = ""
***REMOVED***

variable "fgt_vmsize" {
  default = "Standard_F2s"
***REMOVED***

##############################################################################################################
# Deployment in Microsoft Azure
##############################################################################################################
provider "azurerm" {
  features {***REMOVED***
***REMOVED***

##############################################################################################################
# Static variables
##############################################################################################################
variable "vnet" {
  description = ""
  default     = ["172.16.136.0/22"]
***REMOVED***

variable "subnets" {
  type = list(object({
    name = string
    cidr = list(string)
  ***REMOVED***))
  description = ""

  default = [
    { name = "subnet-external", cidr = ["172.16.136.0/26"] ***REMOVED***, # External
    { name = "subnet-internal", cidr = ["172.16.136.64/26"] ***REMOVED*** # Internal
  ]
***REMOVED***

variable "fortinet_tags" {
  type = map(string)
  default = {
    publisher : "Fortinet",
    template : "A-Single-VM",
    provider : "7EB3B02F-50E5-4A3E-8CB8-2E12925831FGT"
  ***REMOVED***
***REMOVED***

##############################################################################################################

locals {
  fgt_name = "${var.prefix***REMOVED***-fgt"

  fgt_vars = {
    fgt_vm_name                = "${local.fgt_name***REMOVED***"
    fgt_license_file           = var.fgt_byol_license_file
    fgt_license_fortiflex      = var.fgt_byol_fortiflex_license_token
    fgt_username               = var.username
    fgt_ssh_public_key         = var.fgt_ssh_public_key_file
    fgt_external_ipaddr        = local.fgt_ip_configuration["external"]["fgt"]["ipconfig1"].private_ip_address
    fgt_external_mask          = cidrnetmask(azurerm_subnet.subnets["subnet-external"].address_prefixes[0])
    fgt_external_gw            = cidrhost(azurerm_subnet.subnets["subnet-external"].address_prefixes[0], 1)
    fgt_internal_ipaddr        = local.fgt_ip_configuration["internal"]["fgt"]["ipconfig1"].private_ip_address
    fgt_internal_mask          = tostring(cidrnetmask(azurerm_subnet.subnets["subnet-internal"].address_prefixes[0]))
    fgt_internal_gw            = tostring(cidrhost(azurerm_subnet.subnets["subnet-internal"].address_prefixes[0], 1))
    vnet_network               = tostring(azurerm_virtual_network.vnet.address_space[0])
    fgt_additional_custom_data = var.fgt_additional_custom_data
    fgt_fortimanager_ip        = var.fgt_fortimanager_ip
    fgt_fortimanager_serial    = var.fgt_fortimanager_serial
  ***REMOVED***
  fgt_ip_configuration = {
    external = {
      fgt = {
        ipconfig1 = {
          name                          = "ipconfig1"
          private_ip_address            = cidrhost(azurerm_subnet.subnets["subnet-external"].address_prefixes[0], 5)
          private_ip_address_allocation = "Static"
          private_ip_subnet_resource_id = azurerm_subnet.subnets["subnet-external"].id
          is_primary_ipconfiguration    = true
          public_ip_address_resource_id = azurerm_public_ip.fgtpip.id
        ***REMOVED***
      ***REMOVED***
    ***REMOVED***, # External
    internal = {
      fgt = {
        ipconfig1 = {
          name                          = "ipconfig1"
          private_ip_address            = cidrhost(azurerm_subnet.subnets["subnet-internal"].address_prefixes[0], 5)
          private_ip_address_allocation = "Static"
          private_ip_subnet_resource_id = azurerm_subnet.subnets["subnet-internal"].id
          is_primary_ipconfiguration    = true
        ***REMOVED***
      ***REMOVED***
    ***REMOVED*** # Internal
  ***REMOVED***
***REMOVED***
##############################################################################################################
