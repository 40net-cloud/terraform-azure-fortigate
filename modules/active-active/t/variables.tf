variable "prefix" {
  type    = string
  default = ""
***REMOVED***

variable "location" {
  type        = string
  description = "Location of the resource group."
  default     = ""
***REMOVED***

variable "resource_group" {
  type        = string
  description = "resource group name."
  default     = ""
***REMOVED***

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

variable "subnet_name" {
  type        = string
  description = "subnet name"
  default     = ""
***REMOVED***

variable "vnet_name" {
  type        = string
  description = "vnet name"
  default     = ""
***REMOVED***

variable "fgt_serial_console" {
  description = "Enable serial console for FortiGate VM"
  default     = "true"
***REMOVED***

variable "vnet_rg" {
  type        = string
  description = "vnet resource group"
  default     = ""
***REMOVED***

variable "vm_size" {
  type        = string
  description = "vm size"
  default     = ""
***REMOVED***

variable "os_disk_size_gb" {
  type        = string
  description = "vm os disk size gb"
  default     = ""
***REMOVED***

variable "data_disk_size_gb" {
  type        = string
  description = "vm data disk size gb"
  default     = ""
***REMOVED***

variable "admin_username" {
  type        = string
  description = "admin user name"
  default     = ""
***REMOVED***

variable "admin_password" {
  type        = string
  description = "admin user name"
  default     = ""
***REMOVED***

variable "ssh_pub_key" {
  type        = string
  description = "public key for admin user"
  default     = ""
***REMOVED***

variable "data_disk_storage_account_type" {
  type        = string
  description = ""
  default     = ""
***REMOVED***

variable "vm_list" {
  type = map(object({
    hostname = string
  ***REMOVED***))
  default = {
    vm0 = {
      hostname = "node-0"
    ***REMOVED***,
#    vm1 = {
#      hostname = "node-1"
#    ***REMOVED***
    vm2 = {
      hostname = "node-2"
    ***REMOVED***
  ***REMOVED***
***REMOVED***

variable "disks_per_instance" {
  type        = string
  description = ""
  default     = ""
***REMOVED***

provider "azurerm" {
  features {***REMOVED***
***REMOVED***

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.0.0"
    ***REMOVED***
  ***REMOVED***
***REMOVED***