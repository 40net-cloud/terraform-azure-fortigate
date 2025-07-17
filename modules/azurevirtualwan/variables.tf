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
  description = "Azure region for all resources"
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
variable "subscription_id" {
  description = "Azure subscription_id where you deploy all resoureces"
}

variable "managedidentity_id" {
  description = "User assigned managedidentity_id to deploy the managed application."
}

variable "username" {
  description = "Username for the FortiGate VM"
}
variable "password" {
  description = "Password for the FortiGate VM"
  sensitive   = true
}
variable "fgt_vwan_deployment_type" {
  description = "FortiGate deployment type in Azure Virtual WAN. Accepted values: 'sdfw' for SD-WAN + NGFW (Hybrid), or 'ngfw' for NGFW only."
  validation {
    condition     = contains(["sdfw", "ngfw"], var.fgt_vwan_deployment_type)
    error_message = "Deployment type must be either 'sdfw' or 'ngfw'."
  }
}
variable "fgt_image_sku" {
  description = "FortiGate License Type: 'byol' Bring Your Own License or FortiFlex or 'payg' Pay As You Go"
  validation {
    condition     = contains(["byol", "payg"], var.fgt_image_sku)
    error_message = "FortiGate License Type must be either 'byol' or 'payg'."
  }
}
variable "fgt_scaleunit" {
  description = "The scale unit determines the size and number of resources deployed. The higher the scale unit, the greater the amount of traffic that can be handled."
    validation {
    condition     = contains(["2", "4", "10", "20"], var.fgt_scaleunit)
    error_message = "scale unit must be either '2', '4', '10' or '20'."
  }
}
variable "fgt_version" {
  description = "FortiGate version by default the 'latest' available version in the Azure Marketplace is selected"
}
variable "fgt_asn" {
  description = "Local BGP ASN to be used by FortiGates. The default is 64512"
}
variable "tags" {
  type        = map(string)
  description = "A map of tags added to the deployed resources"

#  default = {
#    "environment"  = "VirtualWAN-FortiGate"
#    "publisher"    = "Fortinet"
#  }
}
variable "fortimanager_host" {
  description = "Provide the IP address or DNS name of the FortiManager reachable over port TCP/541"
}
variable "fortimanager_serial" {
  description = "Provide the serial number of the FortiManager"
}
variable "vhub_id" {
  description = "Target virtual WAN hub id. This will be created from terraform in example/main.tf "
}
variable "vhub_virtual_router_ip1" {
  description = "Virtual WAN Hub Router IP1"
}
variable "vhub_virtual_router_ip2" {
  description = "Virtual WAN Hub Router IP2"
}
variable "vhub_virtual_router_asn" {
  description = "Virtual WAN Hub Router BGP ASN"
}
variable "internet_inbound" {
  description = "This option enables the Internet Edge Inbound usecase and creates additional routing infrastructure. The allowed values are true or false."
  type = object({
    enabled        = bool
    public_ip_name = string
    public_ip_rg   = string
  })
}

variable "plan" {
  description = "Managed Application Plan of the marketplace Offer used to deploy"
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
    version   = "7.4.800250704"
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
