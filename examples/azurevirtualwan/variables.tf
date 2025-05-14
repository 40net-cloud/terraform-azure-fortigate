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
}

variable "location" {
  description = "Azure region"
}

variable "username" {}

variable "password" {}

variable "subscription_id" {}

variable "managed_resource_group_name" {}

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

# FortiGate deployment type in Azure Virtual WAN: SDWAN + NGFW (Hybrid) 'sdfw' or NGFW 'ngfw'
variable "fgt_vwan_deployment_type" {
  default = "sdfw"
}

# FortiGate License Type: Bring Your Own License or FortiFlex 'byol' or Pay As You Go 'payg'
variable "fgt_image_sku" {
  default = "byol"
}

variable "fgt_scaleunit" {
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
  default = "172.16.120.0/24"
}

variable "vnet" {
  type        = map(string)
  description = ""

  default = {
    "spoke1" = "172.16.121.0/24"
    "spoke2" = "172.16.122.0/24"
  }
}

variable "spoke_subnet" {
  type        = map(string)
  description = ""

  default = {
    "spoke1" = "172.16.121.0/26"
    "spoke2" = "172.16.122.0/26"
  }
}

variable "fortimanager_host" {
  type = string
}

variable "fortimanager_serial" {
  type = string
}

variable "fgt_asn" {
  type = string

  default = "65007"
}

variable "fgt_version" {
  description = "FortiGate version by default the 'latest' available version in the Azure Marketplace is selected"
  default     = "7.4.4"
}

##############################################################################################################
# Virtual Machines sizes
##############################################################################################################

variable "lnx_vmsize" {
  default = "Standard_B1s"
}
