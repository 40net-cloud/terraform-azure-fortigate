##############################################################################################################
#
# Standalone FortiGate VM
# Terraform deployment template for Microsoft Azure
#
##############################################################################################################
# Variables
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


##############################################################################################################
# Names and data sources of linked Azure resource
##############################################################################################################

variable "resource_group_name" {
  description = "Resource group for all deployed resources"
  type        = string
***REMOVED***

variable "virtual_network_id" {
  description = "Id of the VNET to deploy the FortiGate into"
***REMOVED***

variable "subnet_names" {
  type        = list(string)
  description = "Names of four existing subnets to be connected to FortiGate VMs (external, internal, heartbeat, management)"
  validation {
    condition     = length(var.subnet_names) == 2
    error_message = "Please provide exactly 2 subnet names (external, internal)."
  ***REMOVED***
***REMOVED***

##############################################################################################################
# FortiGate
##############################################################################################################

variable "fgt_image_offer" {
  description = "Azure Marketplace FortiGate Offer (new: 'fortinet_fortigate-vm', old: 'fortinet_fortigate-vm_v5')"
  default = "fortinet_fortigate-vm"
***REMOVED***

variable "fgt_image_sku" {
  description = "Azure Marketplace SKU (new: fortinet_fg-vm_[byol|payg]_[major-minor-version] e.g. fortinet_fg-vm_byol_80, old: PAYG 'fortinet_fg-vm_payg_2023' or byol 'fortinet_fg-vm')"
  default = "fortinet_fg-vm_byol_76"
***REMOVED***

variable "fgt_version" {
  description = "FortiGate version by default the 'latest' available version in the Azure Marketplace is selected"
  default     = "7.6.6"
***REMOVED***

variable "fgt_byol_license_file" {
  description = "BYOL license file path for FGT"
  default = ""
***REMOVED***

variable "fgt_byol_fortiflex_license_token" {
  description = "fortiflex token for FGT"
  default = ""
***REMOVED***

variable "fgt_ssh_public_key_file" {
  default = ""
***REMOVED***

variable "fgt_vmsize" {
  default = "Standard_F2s"
***REMOVED***

variable "fgt_accelerated_networking" {
  description = "Enables Accelerated Networking for the network interfaces of the FortiGate - https://learn.microsoft.com/en-us/azure/virtual-network/accelerated-networking-overview?tabs=redhat#limitations-and-constraints"
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

variable "fgt_datadisk_storage_account_type" {
  description = "Storage account type for FortiGate data disks"
  type        = string
  default     = "Premium_LRS"
***REMOVED***

variable "fgt_additional_custom_data" {
  description = "Additional FortiGate configuration that will be loaded after the default configuration to setup this architecture."
  default     = ""
***REMOVED***

variable "fgt_customdata_variables" {
  type        = map(string)
  description = "FortiGate variables used in default configuration custom data."
  default     = {***REMOVED***
***REMOVED***

variable "fgt_serial_console" {
  description = "Enable serial console for FortiGate VM"
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

variable "fgt_ip_configuration" {
  type = map(object({
    fgt = map(object({
      name = string
      is_primary_ipconfiguration    = optional(bool, true)
      private_ip_address            = optional(string)
      private_ip_address_allocation = optional(string, "Dynamic")
      private_ip_address_version    = optional(string, "IPv4")
      private_ip_subnet_resource_id = optional(string)
      public_ip_address_lock_name   = optional(string)
      public_ip_address_name        = optional(string)
      public_ip_address_resource_id = optional(string)
    ***REMOVED***))
  ***REMOVED***))
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
