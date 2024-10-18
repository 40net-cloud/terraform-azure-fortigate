##############################################################################################################
#
# Fortinet FortiGate Terraform deployment 
# Azure Virtual WAN NVA deployment
#
##############################################################################################################
# Variables
##############################################################################################################

# Prefix for all resources created for this deployment in Microsoft Azure
variable "prefix" {
  description = "Added name to each deployed resource"
***REMOVED***

variable "location" {
  description = "Azure region"
***REMOVED***

variable "username" {***REMOVED***

variable "password" {***REMOVED***

variable "subscription_id" {***REMOVED***

##############################################################################################################
# Deployment in Microsoft Azure
##############################################################################################################
terraform {
  required_version = ">= 0.12"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.12.0"
    ***REMOVED***
  ***REMOVED***
***REMOVED***

provider "azurerm" {
  features {***REMOVED***
  subscription_id = var.subscription_id
***REMOVED***

##############################################################################################################
# Variables
##############################################################################################################

***REMOVED***
variable "fgt_vwan_deployment_type" {
  default = "ngfw"
***REMOVED***

***REMOVED***
variable "fgt_image_sku" {
  default = "payg"
***REMOVED***

variable "fgt_scaleunit" {
  default = "2"
***REMOVED***

variable "tags" {
  type        = map(string)
  description = "A map of tags added to the deployed resources"

#  default = {
#    "environment"  = "VirtualWAN-FortiGate"
#  ***REMOVED***
#  ***REMOVED***
***REMOVED***

variable "vnet_vhub" {
  default = "172.16.120.0/24"
***REMOVED***

variable "vnet" {
  type        = map(string)
  description = ""

  default = {
    "spoke1" = "172.16.121.0/24"
    "spoke2" = "172.16.122.0/24"
  ***REMOVED***
***REMOVED***

variable "spoke_subnet" {
  type        = map(string)
  description = ""

  default = {
    "spoke1" = "172.16.121.0/26"
    "spoke2" = "172.16.122.0/26"
  ***REMOVED***
***REMOVED***

variable "fortimanager_host" {
  type = string
***REMOVED***

variable "fortimanager_serial" {
  type = string
***REMOVED***

variable "fgt_asn" {
  type = string

  default = "65007"
***REMOVED***

variable "fgt_version" {
  description = "FortiGate version by default the 'latest' available version in the Azure Marketplace is selected"
  default     = "7.4.4"
***REMOVED***

##############################################################################################################
# Virtual Machines sizes
##############################################################################################################

variable "lnx_vmsize" {
  default = "Standard_B1s"
***REMOVED***
