##############################################################################################################
#
# Standalone FortiGate VM
# Terraform deployment template for Microsoft Azure
#
##############################################################################################################

variable "prefix" {
  description = "Added name to each deployed resource"
  type        = string
***REMOVED***

variable "location" {
  description = "Azure region"
  type        = string
***REMOVED***

variable "username" {
  description = "Username for FortiGate admin"
  type        = string
***REMOVED***

variable "password" {
  description = "Password for FortiGate admin"
  type        = string
  sensitive   = true
***REMOVED***

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
***REMOVED***

##############################################################################################################
# FortiGate
##############################################################################################################

variable "fgt_image_offer" {
  description = "Azure Marketplace FortiGate Offer (new: 'fortinet_fortigate-vm', old: 'fortinet_fortigate-vm_v5')"
  default     = "fortinet_fortigate-vm"
***REMOVED***

variable "fgt_image_sku" {
  description = "Azure Marketplace SKU (new: fortinet_fg-vm_[byol|payg]_[major-minor-version] e.g. fortinet_fg-vm_byol_80, old: PAYG 'fortinet_fg-vm_payg_2023' or byol 'fortinet_fg-vm')"
  default     = "fortinet_fg-vm_byol_76"
***REMOVED***

variable "fgt_version" {
  description = "FortiGate version by default the 'latest' available version in the Azure Marketplace is selected"
  default     = "7.6.6"
***REMOVED***

variable "fgt_byol_license_file" {
  description = "BYOL license file path for FGT"
  default     = ""
***REMOVED***

variable "fgt_byol_fortiflex_license_token" {
  description = "fortiflex token for FGT"
  default     = ""
***REMOVED***

variable "fgt_ssh_public_key_file" {
  default = ""
***REMOVED***

variable "fgt_accelerated_networking" {
  description = "Enables Accelerated Networking for the network interfaces of the FortiGate"
  default     = "true"
***REMOVED***

variable "fgt_datadisk_size" {
  description = "Size in GB for FortiGate data disks"
  type        = number
  default     = 64
***REMOVED***

variable "fgt_datadisk_count" {
  description = "Number of data disks to attach to each FortiGate"
  type        = number
  default     = 1
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
  description = "Azure VM size for FortiGate instances"
  type        = string
  default     = "Standard_F2s"
***REMOVED***

##############################################################################################################
# Deployment in Microsoft Azure
##############################################################################################################

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.0.0"
    ***REMOVED***
  ***REMOVED***
***REMOVED***
provider "azurerm" {
  features {***REMOVED***
  subscription_id = var.subscription_id
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
    vnet_network               = tostring(tolist(azurerm_virtual_network.vnet.address_space)[0])
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
