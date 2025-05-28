##############################################################################################################
#
# Fortinet FortiGate Terraform deployment
# Azure Virtual WAN NVA deployment
#
##############################################################################################################
# Variables
##############################################################################################################
variable "prefix" {
  description = "Naming prefix for all deployed resources"
***REMOVED***
variable "name" {
  description = "Naming for the deployed FortiGate resources"
***REMOVED***
variable "location" {
  description = "Location for all resources"
***REMOVED***
variable "resource_group" {
  description = "Name and id of the resource group containing the Azure Virtual WAN resources"
  type = object({
    name = string
    id   = string
  ***REMOVED***)
***REMOVED***

variable "managed_resource_group_name" {
  description = "Managed Resource Group Name - defaults to [resource group name]-mrg if nothing provided"
***REMOVED***
variable "subscription_id" {***REMOVED***
variable "username" {
  description = "Username for the FortiGate VM"
***REMOVED***
variable "password" {
  description = "Password for the FortiGate VM"
  sensitive   = true
***REMOVED***
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
