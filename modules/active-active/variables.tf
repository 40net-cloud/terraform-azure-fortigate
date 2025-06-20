##############################################################################################################
#
# FortiGate Active/Active High Availability with Azure Standard Load Balancer - External and Internal
# Terraform deployment template for Microsoft Azure
#
##############################################################################################################
# Variables
##############################################################################################################

variable "prefix" {
  description = "Added name to each deployed resource"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "subscription_id" {
  description = "subscription_id"
  type        = string
}

variable "username" {
  description = "Admin username for the FortiGate VM"
  type        = string
}

variable "password" {
  description = "Admin password for the FortiGate VM"
  type        = string
}

##############################################################################################################
# Names and data sources of linked Azure resource
##############################################################################################################

variable "resource_group_name" {
  description = "Resource group for all deployed resources"
  type        = string
}

variable "virtual_network_id" {
  description = "ID of the VNET to deploy the FortiGate into"
  type        = string
}

variable "virtual_network_address_space" {
  description = "Address space of the VNET to deploy the FortiGate into"
  type        = list(string)
  default     = []
}

variable "subnet_names" {
  type        = list(string)
  description = "Names of two existing subnets to be connected to FortiGate VMs (external, internal)"
  validation {
    condition     = length(var.subnet_names) == 2
    error_message = "Please provide exactly 2 subnet names (external, internal)."
  }
}

##############################################################################################################
# FortiGate
##############################################################################################################

variable "fgt_image_sku" {
  description = "Image SKU - PAYG: 'fortinet_fg-vm_payg_2023' or BYOL: 'fortinet_fg-vm'"
  type        = string
  default     = "fortinet_fg-vm"
}

variable "fgt_version" {
  description = "FortiGate version - 'latest' or specific like '7.4.4'"
  type        = string
  default     = "7.4.4"
}

variable "fgt_byol_license_files" {
  description = "Map of license files keyed by hostname"
  type        = map(string)
  default     = {}
}

variable "fgt_byol_fortiflex_license_tokens" {
  description = "Map of FortiFlex license tokens keyed by hostname"
  type        = map(string)
  default     = {}
}

variable "fgt_ssh_public_key_file" {
  description = "Optional SSH public key file for authentication"
  type        = string
  default     = ""
}

variable "fgt_count" {
  description = "Number of FortiGate instances to deploy"
  type        = number
  default     = 2

  validation {
    condition     = var.fgt_count >= 2 && var.fgt_count <= 8
    error_message = "The number of FortiGate instances must be between 2 and 8."
  }
}

variable "fgt_vmsize" {
  description = "Azure VM size for FortiGate"
  type        = string
  default     = "Standard_F4s"
}

variable "fgt_accelerated_networking" {
  description = "Enable accelerated networking for NICs"
  type        = bool
  default     = true
}

variable "fgt_availability_set" {
  description = "Deploy FortiGate in a new Availability Set"
  type        = bool
  default     = true
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

variable "fgt_config_ha" {
  description = "Enable HA configuration via cloud-init"
  type        = bool
  default     = true
}

variable "fgt_additional_custom_data" {
  description = "Additional FortiGate configuration appended to cloud-init"
  type        = string
  default     = ""
}

variable "fgt_customdata_variables" {
  description = "FortiGate configuration appended to cloud-init"
  type = map(object({
    fgt_vm_name               = string
    fgt_license_file          = string
    fgt_license_fortiflex     = string
    fgt_username              = string
    fgt_ssh_public_key_file   = string
    fgt_config_ha             = bool
    fgt_external_ipaddr       = string
    fgt_external_mask         = string
    fgt_external_gw           = string
    fgt_internal_ipaddr       = string
    fgt_internal_mask         = string
    fgt_internal_gw           = string
    fgt_ha_peerips            = list(string)
    vnet_network              = string
    fgt_additional_custom_data = string
    fgt_fortimanager_ip       = string
    fgt_fortimanager_serial   = string
  }))
}

variable "fgt_serial_console" {
  description = "Enable serial console on FortiGate VMs"
  type        = bool
  default     = true
}

variable "fgt_fortimanager_ip" {
  description = "FortiManager IP address"
  type        = string
  default     = ""
}

variable "fgt_fortimanager_serial" {
  description = "FortiManager serial number"
  type        = string
  default     = ""
}

variable "fgt_ip_configuration" {
  type = object({
    external = map(object({
      ipconfig1 = object({
        name                                                        = string
        app_gateway_backend_pools                                   = optional(map(object({ app_gateway_backend_pool_resource_id = string })), {})
        gateway_load_balancer_frontend_ip_configuration_resource_id = optional(string)
        is_primary_ipconfiguration                                  = optional(bool, true)
        load_balancer_backend_pools                                 = optional(map(object({ load_balancer_backend_pool_resource_id = string })), {})
        load_balancer_nat_rules                                     = optional(map(object({ load_balancer_nat_rule_resource_id = string })), {})
        private_ip_address                                          = optional(string)
        private_ip_address_allocation                               = optional(string, "Dynamic")
        private_ip_address_version                                  = optional(string, "IPv4")
        private_ip_subnet_resource_id                               = optional(string)
      })
    }))
    internal = map(object({
      ipconfig1 = object({
        name                                                        = string
        app_gateway_backend_pools                                   = optional(map(object({ app_gateway_backend_pool_resource_id = string })), {})
        gateway_load_balancer_frontend_ip_configuration_resource_id = optional(string)
        is_primary_ipconfiguration                                  = optional(bool, true)
        load_balancer_backend_pools                                 = optional(map(object({ load_balancer_backend_pool_resource_id = string })), {})
        load_balancer_nat_rules                                     = optional(map(object({ load_balancer_nat_rule_resource_id = string })), {})
        private_ip_address                                          = optional(string)
        private_ip_address_allocation                               = optional(string, "Dynamic")
        private_ip_address_version                                  = optional(string, "IPv4")
        private_ip_subnet_resource_id                               = optional(string)
      })
    }))
  })
}

variable "fortinet_tags" {
  description = "Tags to associate with FortiGate resources"
  type        = map(string)
  default = {
    publisher = "Fortinet"
    template  = "Active-Active-ELB-ILB"
    provider  = "7EB3B02F-50E5-4A3E-8CB8-2E12925831AP"
  }
}
