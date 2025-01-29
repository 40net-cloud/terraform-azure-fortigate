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
# FortiGate
##############################################################################################################

variable "fgt_image_sku" {
  description = "Azure Marketplace default image sku hourly (PAYG 'fortinet_fg-vm_payg_2023') or byol (Bring your own license 'fortinet_fg-vm')"
  #  default     = "fortinet_fg-vm_payg_2023"
  default = "fortinet_fg-vm"
}

variable "fgt_version" {
  description = "FortiGate version by default the 'latest' available version in the Azure Marketplace is selected"
  default     = "7.4.4"
}

variable "fgt_list" {
  default = {
    fgt0 = {
      hostname = "node-0"
    },
    fgt1 = {
      hostname = "node-1"
    }
    fgt2 = {
      hostname = "node-2"
    }
  }
}

variable "fgt_accelerated_networking" {
  description = "Enables Accelerated Networking for the network interfaces of the FortiGate"
  default     = "true"
}

variable "fgt_availability_zone" {
  description = "Deploy FortiGate in a new Availability Zone"
  default     = ["1", "2"]
}

variable "fgt_config_ha" {
  default = "true"
}

variable "fgt_vmsize" {
  default = "Standard_F4s"
}

##############################################################################################################
# Deployment in Microsoft Azure
##############################################################################################################
provider "azurerm" {
  features {}
}

##############################################################################################################
# Networking
##############################################################################################################
variable "vnet" {
  description = ""
  default     = ["172.16.136.0/22", "2001:db8:4::/56"]
}

variable "subnets" {
  type = list(object({
    name = string
    cidr = list(string)
  }))
  description = ""

  default = [
    { name = "subnet-external", cidr = ["172.16.136.0/26", "2001:db8:4:1::/64"] },  # External
    { name = "subnet-internal", cidr = ["172.16.136.64/26", "2001:db8:4:2::/64"] }  # Internal
  ]
}

variable "fortinet_tags" {
  type = map(string)
  default = {
    publisher : "Fortinet",
    template : "Active-Passive-ELB-ILB",
    provider : "7EB3B02F-50E5-4A3E-8CB8-2E12925831AP"
  }
}

##############################################################################################################

locals {
  fgt_name   = "${var.prefix}-fgt"
  fgt_a_name = "${var.prefix}-fgt-a"
  fgt_b_name = "${var.prefix}-fgt-b"

  #  fgt_a_vars = {
  #    fgt_vm_name                = "${local.fgt_a_name}"
  #    fgt_license_file           = var.fgt_byol_license_file_a
  #    fgt_license_fortiflex      = var.fgt_byol_fortiflex_license_token_a
  #    fgt_username               = var.username
  #    fgt_ssh_public_key_file    = var.fgt_ssh_public_key_file
  #    fgt_config_ha              = var.fgt_config_ha
  #    fgt_external_ipaddr        = local.fgt_ip_configuration["external"]["fgt-a"]["ipconfig1"].private_ip_address
  #    fgt_external_mask          = cidrnetmask(azurerm_subnet.subnets["subnet-external"].address_prefixes[0])
  #    fgt_external_gw            = cidrhost(azurerm_subnet.subnets["subnet-external"].address_prefixes[0], 1)
  #    fgt_internal_ipaddr        = local.fgt_ip_configuration["internal"]["fgt-a"]["ipconfig1"].private_ip_address
  #    fgt_internal_mask          = tostring(cidrnetmask(azurerm_subnet.subnets["subnet-internal"].address_prefixes[0]))
  #    fgt_internal_gw            = tostring(cidrhost(azurerm_subnet.subnets["subnet-internal"].address_prefixes[0], 1))
  #    fgt_hasync_ipaddr          = local.fgt_ip_configuration["hasync"]["fgt-a"]["ipconfig1"].private_ip_address
  #    fgt_hasync_mask            = tostring(cidrnetmask(azurerm_subnet.subnets["subnet-hasync"].address_prefixes[0]))
  #    fgt_hasync_gw              = tostring(cidrhost(azurerm_subnet.subnets["subnet-hasync"].address_prefixes[0], 1))
  #    fgt_mgmt_ipaddr            = local.fgt_ip_configuration["hamgmt"]["fgt-a"]["ipconfig1"].private_ip_address
  #    fgt_mgmt_mask              = tostring(cidrnetmask(azurerm_subnet.subnets["subnet-hamgmt"].address_prefixes[0]))
  #    fgt_mgmt_gw                = tostring(cidrhost(azurerm_subnet.subnets["subnet-hamgmt"].address_prefixes[0], 1))
  #    fgt_ha_peerip              = local.fgt_ip_configuration["hasync"]["fgt-b"]["ipconfig1"].private_ip_address
  #    fgt_ha_priority            = "255"
  #    vnet_network               = tostring(azurerm_virtual_network.vnet.address_space[0])
  #    fgt_additional_custom_data = var.fgt_additional_custom_data
  #    fgt_fortimanager_ip        = var.fgt_fortimanager_ip
  #    fgt_fortimanager_serial    = var.fgt_fortimanager_serial
  #  }
  #  fgt_b_vars = {
  #    fgt_vm_name                = "${local.fgt_b_name}"
  #    fgt_license_file           = var.fgt_byol_license_file_b
  #    fgt_license_fortiflex      = var.fgt_byol_fortiflex_license_token_b
  #    fgt_username               = var.username
  #    fgt_ssh_public_key_file    = var.fgt_ssh_public_key_file
  #    fgt_config_ha              = var.fgt_config_ha
  #    fgt_external_ipaddr        = local.fgt_ip_configuration["external"]["fgt-b"]["ipconfig1"].private_ip_address
  #    fgt_external_mask          = cidrnetmask(azurerm_subnet.subnets["subnet-external"].address_prefixes[0])
  #    fgt_external_gw            = cidrhost(azurerm_subnet.subnets["subnet-external"].address_prefixes[0], 1)
  #    fgt_internal_ipaddr        = local.fgt_ip_configuration["internal"]["fgt-b"]["ipconfig1"].private_ip_address
  #    fgt_internal_mask          = cidrnetmask(azurerm_subnet.subnets["subnet-internal"].address_prefixes[0])
  #    fgt_internal_gw            = cidrhost(azurerm_subnet.subnets["subnet-internal"].address_prefixes[0], 1)
  #    fgt_hasync_ipaddr          = local.fgt_ip_configuration["hasync"]["fgt-b"]["ipconfig1"].private_ip_address
  #    fgt_hasync_mask            = cidrnetmask(azurerm_subnet.subnets["subnet-hasync"].address_prefixes[0])
  #    fgt_hasync_gw              = cidrhost(azurerm_subnet.subnets["subnet-hasync"].address_prefixes[0], 1)
  #    fgt_mgmt_ipaddr            = local.fgt_ip_configuration["hasync"]["fgt-b"]["ipconfig1"].private_ip_address
  #    fgt_mgmt_mask              = cidrnetmask(azurerm_subnet.subnets["subnet-hamgmt"].address_prefixes[0])
  #    fgt_mgmt_gw                = cidrhost(azurerm_subnet.subnets["subnet-hamgmt"].address_prefixes[0], 1)
  #    fgt_ha_peerip              = local.fgt_ip_configuration["hasync"]["fgt-a"]["ipconfig1"].private_ip_address
  #    fgt_ha_priority            = "1"
  #    vnet_network               = tostring(azurerm_virtual_network.vnet.address_space[0])
  #    fgt_additional_custom_data = var.fgt_additional_custom_data
  #    fgt_fortimanager_ip        = var.fgt_fortimanager_ip
  #    fgt_fortimanager_serial    = var.fgt_fortimanager_serial
  #  }
  fgt_ip_configuration = {
    external = {
      ipconfig1 = {
        name                          = "ipconfig1"
        private_ip_address_allocation = "Dynamic"
        private_ip_address_version    = "IPv4"
        private_ip_subnet_resource_id = azurerm_subnet.subnets["subnet-external"].id
        is_primary_ipconfiguration    = true
      }
    }, # External
    internal = {
      ipconfig1 = {
        name                          = "ipconfig1"
        private_ip_address_allocation = "Dynamic"
        private_ip_address_version    = "IPv4"
        private_ip_subnet_resource_id = azurerm_subnet.subnets["subnet-internal"].id
        is_primary_ipconfiguration    = true
      }
    } # Internal
  }
}

##############################################################################################################
