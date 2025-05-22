##############################################################################################################
#
# Fortinet FortiGate Terraform deployment
# Azure Virtual WAN NVA deployment
#
##############################################################################################################
# Variables
##############################################################################################################
variable "prefix" {***REMOVED***
variable "name" {***REMOVED***
variable "location" {***REMOVED***
variable "resource_group" {
  type = object({
    name = string
    id   = string
  ***REMOVED***)
***REMOVED***

variable "managed_resource_group_name" {
  description = "Managed Resource Group Name - defaults to [resource group name]-mrg if nothing provided"
***REMOVED***
variable "subscription_id" {***REMOVED***
variable "username" {***REMOVED***
variable "password" {***REMOVED***
variable "fgt_vwan_deployment_type" {***REMOVED***
variable "fgt_image_sku" {***REMOVED***
variable "fgt_scaleunit" {***REMOVED***
variable "fgt_version" {***REMOVED***
variable "fgt_asn" {***REMOVED***
variable "tags" {***REMOVED***
variable "fortimanager_host" {***REMOVED***
variable "fortimanager_serial" {***REMOVED***
variable "vhub_id" {***REMOVED***
variable "vhub_virtual_router_ip1" {***REMOVED***
variable "vhub_virtual_router_ip2" {***REMOVED***
variable "vhub_virtual_router_asn" {***REMOVED***
variable "internet_inbound" {
  type = object({
    enabled        = bool
    public_ip_name = string
    public_ip_rg   = string
  ***REMOVED***)
***REMOVED***

variable "plan" {
  type = object({
    name      = string
    product   = string
    publisher = string
    version   = string
  ***REMOVED***)
  default = {
    name      = "fortigate-managedvwan"
    product   = "fortigate_vwan_nva"
    publisher = "fortinet"
    version   = "7.4.500250218"
  ***REMOVED***
***REMOVED***

##############################################################################################################
# Provider
##############################################################################################################
terraform {
  required_version = ">= 0.12"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.12.0"
    ***REMOVED***
    azapi = {
      source  = "azure/azapi"
      version = ">=2.3.0"
    ***REMOVED***
  ***REMOVED***
***REMOVED***
