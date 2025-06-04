##############################################################################################################
#
# Fortinet FortiGate Terraform deployment 
# Azure Virtual WAN NVA deployment
#
##############################################################################################################
# Variables
##############################################################################################################

variable "prefix" {
  description = "Added name to each deployed resource"
}

variable "location" {
  description = "Azure region for all resources"
}

variable "username" {
  description = "Fortigate username. Do no use reserved usernames like admin, root, administrator"
}

variable "password" {
  description = "Fortigate password. Use a password that has at least 12 characters and use lowercase, uppercase, numbers and non-alphanumeric characters"
}

variable "subscription_id" {
  description = " Azure subscription_id where you deploy all resoureces"
}

variable "managedidentity_id" {
  description = " user assigned managedidentity_id to deploy the managed application."
}

variable "managed_resource_group_name" {
  description = " Managed resource group name - a resource group used to deploy the FortiGate NVA into. It will be created during deployment and should not exist"
}

##############################################################################################################
# Deployment in Microsoft Azure
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
      version = ">2.0.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

##############################################################################################################
# Variables
##############################################################################################################

variable "fgt_vwan_deployment_type" {
  description = "FortiGate deployment type in Azure Virtual WAN. Accepted values: 'sdfw' for SD-WAN + NGFW (Hybrid), or 'ngfw' for NGFW only."
  default = "sdfw"
}

variable "fgt_image_sku" {
  description = "FortiGate License Type: 'byol' Bring Your Own License or FortiFlex or 'payg' Pay As You Go"
  default = "byol"
}

variable "fgt_scaleunit" {
  description = "The scale unit determines the size and number of resources deployed. The higher the scale unit, the greater the amount of traffic that can be handled."
  default = "2"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags added to the deployed resources"

#  default = {
#    "environment"  = "VirtualWAN-FortiGate"
#    "publisher"    = "Fortinet"
#  }
}

variable "vnet_vhub" {
  description = "address_prefix for vnet virtual hub" 
  default = "172.16.120.0/24"
}

variable "vnet" {
  type        = map(string)
  description = "address_prefix for vnet: spoke1 and spoke2" 

  default = {
    "spoke1" = "172.16.121.0/24"
    "spoke2" = "172.16.122.0/24"
  }
}

variable "spoke_subnet" {
  type        = map(string)
  description = "address_prefix for subnet: spoke1subnet1 and spoke2subnet1"

  default = {
    "spoke1" = "172.16.121.0/26"
    "spoke2" = "172.16.122.0/26"
  }
}

variable "fortimanager_host" {
  description = "Provide the IP address or DNS name of the FortiManager reachable over port TCP/541"
  type = string
}

variable "fortimanager_serial" {
  description = "Provide the serial number of the FortiManager"
  type = string
}

variable "fgt_asn" {
  description = "Local BGP ASN to be used by FortiGates. The default is 64512"
  type = string
  default = "64512"
}

variable "fgt_version" {
  description = "FortiGate version by default the 'latest' available version in the Azure Marketplace is selected"
  default     = "7.4.7"
}

##############################################################################################################
# Virtual Machines sizes
##############################################################################################################

variable "lnx_vmsize" {
  description = "Linux virtual machine instance type in spoke1 and spoke2 "
  default = "Standard_B1s"
}
