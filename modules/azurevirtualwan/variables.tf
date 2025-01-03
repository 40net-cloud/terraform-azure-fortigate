##############################################################################################################
#
# Fortinet FortiGate Terraform deployment
# Azure Virtual WAN NVA deployment
#
##############################################################################################################
# Variables
##############################################################################################################
variable "prefix" {}
variable "name" {}
variable "location" {}
variable "resource_group_name" {}
variable "username" {}
variable "password" {}
variable "deployment_type" {}
variable "sku" {}
variable "scaleunit" {}
variable "mpversion" {}
variable "asn" {}
variable "tags" {}
variable "fortimanager_host" {}
variable "fortimanager_serial" {}
variable "vhub_id" {}
variable "vhub_virtual_router_ip1" {}
variable "vhub_virtual_router_ip2" {}
variable "vhub_virtual_router_asn" {}
variable "internet_inbound_enabled" {}
variable "internet_inbound_public_ip_rg" {}
variable "internet_inbound_public_ip_name" {}

variable "managed_resource_group_name" {
  description = "Managed Resource Group Name - defaults to [resource group name]-mrg if nothing provided"
  default = ""
}

##############################################################################################################
# Provider
##############################################################################################################
terraform {
  required_version = ">= 0.12"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.12.0"
    }
  }
}
