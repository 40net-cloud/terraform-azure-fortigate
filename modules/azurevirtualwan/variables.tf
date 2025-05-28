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
}
variable "name" {
  description = "Naming for the deployed FortiGate resources"
}
variable "location" {
  description = "Location for all resources"
}
variable "resource_group" {
  description = "Name and id of the resource group containing the Azure Virtual WAN resources"
  type = object({
    name = string
    id   = string
  })
}

variable "managed_resource_group_name" {
  description = "Managed Resource Group Name - defaults to [resource group name]-mrg if nothing provided"
}
variable "subscription_id" {}
variable "username" {
  description = "Username for the FortiGate VM"
}
variable "password" {
  description = "Password for the FortiGate VM"
  sensitive   = true
}
variable "fgt_vwan_deployment_type" {}
variable "fgt_image_sku" {}
variable "fgt_scaleunit" {}
variable "fgt_version" {}
variable "fgt_asn" {}
variable "tags" {}
variable "fortimanager_host" {}
variable "fortimanager_serial" {}
variable "vhub_id" {}
variable "vhub_virtual_router_ip1" {}
variable "vhub_virtual_router_ip2" {}
variable "vhub_virtual_router_asn" {}
variable "internet_inbound" {
  type = object({
    enabled        = bool
    public_ip_name = string
    public_ip_rg   = string
  })
}

variable "plan" {
  type = object({
    name      = string
    product   = string
    publisher = string
    version   = string
  })
  default = {
    name      = "fortigate-managedvwan"
    product   = "fortigate_vwan_nva"
    publisher = "fortinet"
    version   = "7.4.500250218"
  }
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
    azapi = {
      source  = "azure/azapi"
      version = ">=2.3.0"
    }
  }
}
