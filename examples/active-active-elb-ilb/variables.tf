##############################################################################################################
#
# FortiGate Active/Active High Availability with Azure Standard Load Balancer - External and Internal
# Terraform deployment template for Microsoft Azure
#
##############################################################################################################

variable "prefix" {
  description = "Added name to each deployed resource"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "username" {
  description = "Username for FortiGate admin"
  type        = string
}

variable "password" {
  description = "Password for FortiGate admin"
  type        = string
  sensitive   = true
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

##############################################################################################################
# FortiGate Image and Version
##############################################################################################################

variable "fgt_image_sku" {
  description = "Azure Marketplace image SKU: PAYG ('fortinet_fg-vm_payg_2023') or BYOL ('fortinet_fg-vm')"
  type        = string
  default     = "fortinet_fg-vm"
}

variable "fgt_version" {
  description = "FortiGate version, defaults to latest available in Azure Marketplace"
  type        = string
  default     = "7.4.4"
}

##############################################################################################################
# FortiGate Instances Dynamic Configuration
##############################################################################################################

variable "fgt_count" {
  description = "Number of FortiGate instances to deploy"
  type        = number
  default     = 2

  validation {
    condition     = var.fgt_count >= 2 && var.fgt_count <= 8
    error_message = "The number of FortiGate instances must be between 2 and 8."
  }
}

variable "fgt_hostnames" {
  description = "Optional list of hostnames for FortiGate instances (overrides default node-N naming)"
  type        = list(string)
  default     = []
}

variable "fgt_accelerated_networking" {
  description = "Enables Accelerated Networking for FortiGate NICs"
  type        = bool
  default     = true
}

variable "fgt_availability_set" {
  description = "Deploy FortiGate in a new Availability Set"
  type        = bool
  default     = false
}

variable "fgt_availability_zone" {
  description = "Availability Zones for FortiGate VMs"
  type        = list(string)
  default     = ["1", "2"]

  validation {
    condition     = length(var.fgt_availability_zone) <= 3
    error_message = "You can specify up to 3 availability zones only (0 to 3 entries)."
  }
}

variable "fgt_config_ha" {
  description = "Enable High Availability configuration for FortiGate"
  type        = bool
  default     = true
}

variable "fgt_vmsize" {
  description = "Azure VM size for FortiGate instances"
  type        = string
  default     = "Standard_F4s"
}

variable "fgt_datadisk_size" {
  description = "Size in GB for FortiGate data disks"
  type        = number
  default     = 64
}

variable "fgt_datadisk_count" {
  description = "Number of data disks to attach to each FortiGate"
  type        = number
  default     = 1
}

variable "fgt_serial_console" {
  description = "Enable serial console on FortiGate VMs"
  type        = bool
  default     = true
}

variable "fgt_byol_license_files" {
  description = "Map of BYOL license file paths keyed by hostname"
  type        = map(string)
  default     = {}
}

variable "fgt_byol_fortiflex_license_tokens" {
  description = "Map of FortiFlex license tokens keyed by hostname"
  type        = map(string)
  default     = {}
}

variable "fgt_ssh_public_key_file" {
  description = "Path to the SSH public key file for FortiGate instances"
  type        = string
}

variable "fgt_additional_custom_data" {
  description = "Optional cloud-init custom data for FortiGate instances"
  type        = string
  default     = ""
}

variable "fgt_fortimanager_ip" {
  description = "IP address of the FortiManager"
  type        = string
  default     = ""
}

variable "fgt_fortimanager_serial" {
  description = "Serial number of the FortiManager"
  type        = string
  default     = ""
}

##############################################################################################################
# Networking
##############################################################################################################

variable "vnet" {
  description = "Virtual Network address spaces"
  type        = list(string)
  default     = ["172.16.136.0/22", "2001:db8:4::/56"]
}

variable "subnets" {
  description = "List of subnets with names and CIDR blocks"
  type = list(object({
    name = string
    cidr = list(string)
  }))
  default = [
    { name = "subnet-external", cidr = ["172.16.136.0/26", "2001:db8:4:1::/64"] },
    { name = "subnet-internal", cidr = ["172.16.136.64/26", "2001:db8:4:2::/64"] }
  ]
}

##############################################################################################################
# Fortinet Tags
##############################################################################################################

variable "fortinet_tags" {
  description = "Tags applied to Fortinet resources"
  type        = map(string)
  default = {
    publisher = "Fortinet",
    template  = "Active-Active-ELB-ILB",
    provider  = "7EB3B02F-50E5-4A3E-8CB8-2E12925831AP"
  }
}

##############################################################################################################

locals {
  # Generate list of FortiGate hostnames, fallback to "node-0", "node-1", etc.
  fgt_hostnames = length(var.fgt_hostnames) > 0 ? var.fgt_hostnames : [for i in range(var.fgt_count) : "node-${i}"]

  # Generate VM names for each FortiGate
  fgt_vm_names = [for name in local.fgt_hostnames : "${var.prefix}-${name}"]

  fgt_peer_ips = {
    for current in local.fgt_hostnames : current => [
      for peer in local.fgt_hostnames : local.fgt_ip_configuration.internal[peer].ipconfig1.private_ip_address
      if peer != current
    ]
  }

  # Map of variables per FortiGate instance
  fgt_vars = {
    for idx, hostname in local.fgt_hostnames : hostname => {
      fgt_vm_name             = local.fgt_vm_names[idx]
      fgt_license_file        = lookup(var.fgt_byol_license_files, hostname, "")
      fgt_license_fortiflex   = lookup(var.fgt_byol_fortiflex_license_tokens, hostname, "")
      fgt_username            = var.username
      fgt_ssh_public_key_file = var.fgt_ssh_public_key_file
      fgt_config_ha           = var.fgt_config_ha

      fgt_external_ipaddr     = local.fgt_ip_configuration["external"][hostname]["ipconfig1"].private_ip_address
      fgt_external_mask       = cidrnetmask(azurerm_subnet.subnets["subnet-external"].address_prefixes[0])
      fgt_external_gw         = cidrhost(azurerm_subnet.subnets["subnet-external"].address_prefixes[0], 1)

      fgt_internal_ipaddr     = local.fgt_ip_configuration["internal"][hostname]["ipconfig1"].private_ip_address
      fgt_internal_mask       = cidrnetmask(azurerm_subnet.subnets["subnet-internal"].address_prefixes[0])
      fgt_internal_gw         = cidrhost(azurerm_subnet.subnets["subnet-internal"].address_prefixes[0], 1)
      fgt_ha_peerips           = local.fgt_peer_ips[hostname]

      vnet_network = tostring(tolist(azurerm_virtual_network.vnet.address_space)[0])
      fgt_additional_custom_data = var.fgt_additional_custom_data
      fgt_fortimanager_ip     = var.fgt_fortimanager_ip
      fgt_fortimanager_serial = var.fgt_fortimanager_serial
    }
  }

  # IP configuration only for external and internal subnets
  fgt_ip_configuration = {
    external = {
      for idx, hostname in local.fgt_hostnames : hostname => {
        ipconfig1 = {
          name                          = "ipconfig1"
          private_ip_address            = cidrhost(azurerm_subnet.subnets["subnet-external"].address_prefixes[0], 5 + idx)
          private_ip_address_allocation = "Static"
          private_ip_address_version    = "IPv4"
          private_ip_subnet_resource_id = azurerm_subnet.subnets["subnet-external"].id
          is_primary_ipconfiguration    = true
          load_balancer_backend_pools = {
            lb_pool_1 = {
              load_balancer_backend_pool_resource_id = module.elb.azurerm_lb_backend_address_pool_id
            }
          }
        }
      }
    }
    internal = {
      for idx, hostname in local.fgt_hostnames : hostname => {
        ipconfig1 = {
          name                          = "ipconfig1"
          private_ip_address            = cidrhost(azurerm_subnet.subnets["subnet-internal"].address_prefixes[0], 5 + idx)
          private_ip_address_allocation = "Static"
          private_ip_address_version    = "IPv4"
          private_ip_subnet_resource_id = azurerm_subnet.subnets["subnet-internal"].id
          is_primary_ipconfiguration    = true
           load_balancer_backend_pools = {
            lb_pool_1 = {
              load_balancer_backend_pool_resource_id = module.ilb.azurerm_lb_backend_address_pool_id
            }
          }
        }
      }
    }
  }
}

##############################################################################################################
# Versions 
##############################################################################################################

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.0.0"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

##############################################################################################################
