##############################################################################################################
#
# FortiGate Active/Passive High Availability with Azure Standard Load Balancer - External and Internal
# Terraform deployment template for Microsoft Azure
#
##############################################################################################################
# Variables
##############################################################################################################

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
# Names and data sources of linked Azure resource
##############################################################################################################

variable "resource_group_name" {
}

variable "virtual_network_name" {
  description = "Name of the VNET to deploy the FortiGate into"
}

data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

variable "subnet_names" {
  type        = list(string)
  description = "Names of four existing subnets to be connected to FortiGate VMs (external, internal, heartbeat, management)"
  validation {
    condition     = length(var.subnet_names) == 2
    error_message = "Please provide exactly 2 subnet names (external, internal)."
  }
}

data "azurerm_subnet" "subnet1" {
  name                 = var.subnet_names[0]
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
}

data "azurerm_subnet" "subnet2" {
  name                 = var.subnet_names[1]
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
}

##############################################################################################################
# FortiGate
##############################################################################################################

variable "fgt_image_sku" {
  description = "Azure Marketplace default image sku hourly (PAYG 'fortinet_fg-vm_payg_2023') or byol (Bring your own license 'fortinet_fg-vm')"
  #  default     = "fortinet_fg-vm_payg_2023"
  default = "fortinet_fg-vm"
}

variable "fgt_version" {
  description = "FortiGate version by default the 'latest' available version in the Azure Marketplace is selected"
  default     = "7.2.8"
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

variable "fgt_vmsize" {
  default = "Standard_F2s"
}

variable "fgt_accelerated_networking" {
  description = "Enables Accelerated Networking for the network interfaces of the FortiGate"
  default     = "true"
}

variable "fgt_additional_custom_data" {
  description = "Additional FortiGate configuration that will be loaded after the default configuration to setup this architecture."
  default     = ""
}

variable "fgt_serial_console" {
  description = "Enabled serial console for FortiGate VM"
  default     = "true"
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
