##############################################################################################################
#
# FortiGate a standalone FortiGate VM
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

variable "fgt_accelerated_networking" {
  description = "Enables Accelerated Networking for the network interfaces of the FortiGate"
  default     = "true"
}

variable "fgt_fortimanager_ip" {
  description = "FortiManager Central Management IP address"
  default     = ""
}

variable "fgt_fortimanager_serial" {
  description = "FortiManager Central Management serial number for registration"
  default     = ""
}

variable "fgt_additional_custom_data" {
  description = "Additional FortiGate configuration that will be loaded after the default configuration to setup this architecture."
  default     = ""
}

variable "fgt_vmsize" {
  default = "Standard_F2s"
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
  default     = ["172.16.136.0/22"]
}

variable "subnets" {
  type = list(object({
    name = string
    cidr = list(string)
  }))
  description = ""

  default = [
    { name = "subnet-external", cidr = ["172.16.136.0/26"] }, # External
    { name = "subnet-internal", cidr = ["172.16.136.64/26"] } # Internal
  ]
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

locals {
  fgt_name = "${var.prefix}-fgt"

  fgt_vars = {
    fgt_vm_name                = "${local.fgt_name}"
    fgt_license_file           = var.fgt_byol_license_file
    fgt_license_fortiflex      = var.fgt_byol_fortiflex_license_token
    fgt_username               = var.username
    fgt_ssh_public_key         = var.fgt_ssh_public_key_file
    fgt_external_ipaddr        = local.fgt_ip_configuration["external"]["fgt"]["ipconfig1"].private_ip_address
    fgt_external_mask          = cidrnetmask(azurerm_subnet.subnets["subnet-external"].address_prefixes[0])
    fgt_external_gw            = cidrhost(azurerm_subnet.subnets["subnet-external"].address_prefixes[0], 1)
    fgt_internal_ipaddr        = local.fgt_ip_configuration["internal"]["fgt"]["ipconfig1"].private_ip_address
    fgt_internal_mask          = tostring(cidrnetmask(azurerm_subnet.subnets["subnet-internal"].address_prefixes[0]))
    fgt_internal_gw            = tostring(cidrhost(azurerm_subnet.subnets["subnet-internal"].address_prefixes[0], 1))
    vnet_network               = tostring(azurerm_virtual_network.vnet.address_space[0])
    fgt_additional_custom_data = var.fgt_additional_custom_data
    fgt_fortimanager_ip        = var.fgt_fortimanager_ip
    fgt_fortimanager_serial    = var.fgt_fortimanager_serial
  }
  fgt_ip_configuration = {
    external = {
      fgt = {
        ipconfig1 = {
          name                          = "ipconfig1"
          private_ip_address            = cidrhost(azurerm_subnet.subnets["subnet-external"].address_prefixes[0], 5)
          private_ip_address_allocation = "Static"
          private_ip_subnet_resource_id = azurerm_subnet.subnets["subnet-external"].id
          is_primary_ipconfiguration    = true
          public_ip_address_resource_id = azurerm_public_ip.fgtpip.id
        }
      }
    }, # External
    internal = {
      fgt = {
        ipconfig1 = {
          name                          = "ipconfig1"
          private_ip_address            = cidrhost(azurerm_subnet.subnets["subnet-internal"].address_prefixes[0], 5)
          private_ip_address_allocation = "Static"
          private_ip_subnet_resource_id = azurerm_subnet.subnets["subnet-internal"].id
          is_primary_ipconfiguration    = true
        }
      }
    } # Internal
  }
}
##############################################################################################################
