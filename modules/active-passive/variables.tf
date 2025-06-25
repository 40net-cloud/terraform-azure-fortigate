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
}

variable "subnet_names" {
  type        = list(string)
  description = "Names of four existing subnets to be connected to FortiGate VMs (external, internal, heartbeat, management)"
  validation {
    condition     = length(var.subnet_names) == 4
    error_message = "Please provide exactly 4 subnet names (external, internal, heartbeat, management)."
  }
}

##############################################################################################################
# FortiGate
##############################################################################################################

variable "fgt_image_sku" {
  description = "Azure Marketplace default image sku hourly (PAYG 'fortinet_fg-vm_payg_2023') or byol (Bring your own license 'fortinet_fg-vm')"
  default = "fortinet_fg-vm"
}

variable "fgt_version" {
  description = "FortiGate version by default the 'latest' available version in the Azure Marketplace is selected"
  default     = "7.2.8"
}

variable "fgt_byol_license_file_a" {
  description = "BYOL license file for FGT_a"
  default = ""
}

variable "fgt_byol_license_file_b" {
  description = "BYOL license file for FGT_b"
  default = ""
}

variable "fgt_byol_fortiflex_license_token_a" {
  description = "fortiflex token for FGT_a"
  default     = ""
}

variable "fgt_byol_fortiflex_license_token_b" {
  description = "fortiflex token for FGT_b"
  default = ""
}

variable "fgt_ssh_public_key_file" {
  default = ""
}

variable "fgt_vmsize" {
  default = "Standard_F4s"
}

variable "fgt_accelerated_networking" {
  description = "Enables Accelerated Networking for the network interfaces of the FortiGate - https://learn.microsoft.com/en-us/azure/virtual-network/accelerated-networking-overview?tabs=redhat#limitations-and-constraints"
  default     = "true"
}

variable "fgt_availability_set" {
  description = "Deploy FortiGate in a new Availability Set"
  default     = "true"
}

variable "fgt_availability_zone" {
  description = "Deploy FortiGate in Availability Zones"
  default     = ["1", "2"]
}

variable "fgt_datadisk_size" {
  default = 50
}

variable "fgt_datadisk_count" {
  default = 1
}

variable "fgt_config_ha" {
  description = "Automatically configures the FGCP HA configuration using cloudinit"
  default     = "true"
}

variable "fgt_additional_custom_data" {
  description = "Additional FortiGate configuration that will be loaded after the default configuration to setup this architecture."
  default     = ""
}

variable "fgt_a_customdata_variables" {
  type        = map(string)
  description = "FortiGate variables used in default configuration custom data."
  default     = {}
}

variable "fgt_b_customdata_variables" {
  type        = map(string)
  description = "FortiGate variables used in default configuration custom data."
  default     = {}
}

variable "fgt_serial_console" {
  description = "Enable serial console for FortiGate VM"
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

variable "fgt_ip_configuration" {
  type = map(object({
    fgt-a = map(object({
      name = string
      app_gateway_backend_pools = optional(map(object({
        app_gateway_backend_pool_resource_id = string
      })), {})
      gateway_load_balancer_frontend_ip_configuration_resource_id = optional(string)
      is_primary_ipconfiguration                                  = optional(bool, true)
      load_balancer_backend_pools = optional(map(object({
        load_balancer_backend_pool_resource_id = string
      })), {})
      load_balancer_nat_rules = optional(map(object({
        load_balancer_nat_rule_resource_id = string
      })), {})
      private_ip_address            = optional(string)
      private_ip_address_allocation = optional(string, "Dynamic")
      private_ip_address_version    = optional(string, "IPv4")
      private_ip_subnet_resource_id = optional(string)
      public_ip_address_lock_name   = optional(string)
      public_ip_address_name        = optional(string)
      public_ip_address_resource_id = optional(string)
    }))
    fgt-b = map(object({
      name = string
      app_gateway_backend_pools = optional(map(object({
        app_gateway_backend_pool_resource_id = string
      })), {})
      gateway_load_balancer_frontend_ip_configuration_resource_id = optional(string)
      is_primary_ipconfiguration                                  = optional(bool, true)
      load_balancer_backend_pools = optional(map(object({
        load_balancer_backend_pool_resource_id = string
      })), {})
      load_balancer_nat_rules = optional(map(object({
        load_balancer_nat_rule_resource_id = string
      })), {})
      private_ip_address            = optional(string)
      private_ip_address_allocation = optional(string, "Dynamic")
      private_ip_address_version    = optional(string, "IPv4")
      private_ip_subnet_resource_id = optional(string)
      public_ip_address_lock_name   = optional(string)
      public_ip_address_name        = optional(string)
      public_ip_address_resource_id = optional(string)
    }))
  }))
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
