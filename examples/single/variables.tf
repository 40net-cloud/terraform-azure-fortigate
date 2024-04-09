##############################################################################################################
#
# FortiGate Active/Passive High Availability with Azure Standard Load Balancer - External and Internal
# Terraform deployment template for Microsoft Azure
#
##############################################################################################################

# Prefix for all resources created for this deployment in Microsoft Azure
variable "prefix" {
  description = "Added name to each deployed resource"
}

variable "location" {
  description = "Azure region"
}

variable "username" {
}

variable "password" {
}

##############################################################################################################
# FortiGate license type
##############################################################################################################

variable "fgt_image_sku" {
  description = "Azure Marketplace default image sku hourly (PAYG 'fortinet_fg-vm_payg_2023') or byol (Bring your own license 'fortinet_fg-vm')"
#  default     = "fortinet_fg-vm_payg_2023"
  default     = "fortinet_fg-vm"
}

variable "fgt_version" {
  description = "FortiGate version by default the 'latest' available version in the Azure Marketplace is selected"
  default     = "7.4.3"
}

variable "fgt_byol_license_file" {
  default = ""
}

variable "fgt_byol_fortiflex_license_token" {
  default = ""
}

variable "fgt_ssh_public_key_file" {
  default = ""
}

variable "fgt_accelerated_networking" {
  description = "Enables Accelerated Networking for the network interfaces of the FortiGate"
  default     = "true"
}

##############################################################################################################
# Deployment in Microsoft Azure
##############################################################################################################
provider "azurerm" {
  features {}
}

##############################################################################################################
# Static variables
##############################################################################################################
variable "vnet" {
  description = ""
  default     = "172.16.136.0/22"
}

variable "subnets" {
  type        = list(string)
  description = ""

  default = [
    "172.16.136.0/26",   # External
    "172.16.136.64/26",  # Internal
  ]
}

variable "fgt_vmsize" {
  default = "Standard_F2s"
}

variable "fortinet_tags" {
  type = map(string)
  default = {
    publisher : "Fortinet",
    template : "A-Single-VM",
    provider : "7EB3B02F-50E5-4A3E-8CB8-2E12925831FGT"
  }
}

##############################################################################################################
