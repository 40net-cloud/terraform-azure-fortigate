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
variable "resource_group_name" {***REMOVED***
variable "username" {***REMOVED***
variable "password" {***REMOVED***
variable "deployment_type" {***REMOVED***
variable "sku" {***REMOVED***
variable "scaleunit" {***REMOVED***
variable "mpversion" {***REMOVED***
variable "asn" {***REMOVED***
variable "tags" {***REMOVED***
variable "fortimanager_host" {***REMOVED***
variable "fortimanager_serial" {***REMOVED***
variable "vhub_id" {***REMOVED***
variable "vhub_virtual_router_ip1" {***REMOVED***
variable "vhub_virtual_router_ip2" {***REMOVED***
variable "vhub_virtual_router_asn" {***REMOVED***
variable "internet_inbound_enabled" {***REMOVED***
variable "internet_inbound_public_ip_rg" {***REMOVED***
variable "internet_inbound_public_ip_name" {***REMOVED***

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
  ***REMOVED***
***REMOVED***
