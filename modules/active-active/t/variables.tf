variable "prefix" {
  type    = string
  default = ""
}

variable "location" {
  type        = string
  description = "Location of the resource group."
  default     = ""
}

variable "resource_group" {
  type        = string
  description = "resource group name."
  default     = ""
}

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

variable "subnet_name" {
  type        = string
  description = "subnet name"
  default     = ""
}

variable "vnet_name" {
  type        = string
  description = "vnet name"
  default     = ""
}

variable "fgt_serial_console" {
  description = "Enable serial console for FortiGate VM"
  default     = "true"
}

variable "vnet_rg" {
  type        = string
  description = "vnet resource group"
  default     = ""
}

variable "vm_size" {
  type        = string
  description = "vm size"
  default     = ""
}

variable "os_disk_size_gb" {
  type        = string
  description = "vm os disk size gb"
  default     = ""
}

variable "data_disk_size_gb" {
  type        = string
  description = "vm data disk size gb"
  default     = ""
}

variable "admin_username" {
  type        = string
  description = "admin user name"
  default     = ""
}

variable "admin_password" {
  type        = string
  description = "admin user name"
  default     = ""
}

variable "ssh_pub_key" {
  type        = string
  description = "public key for admin user"
  default     = ""
}

variable "data_disk_storage_account_type" {
  type        = string
  description = ""
  default     = ""
}

variable "vm_list" {
  type = map(object({
    hostname = string
  }))
  default = {
    vm0 = {
      hostname = "node-0"
    },
#    vm1 = {
#      hostname = "node-1"
#    }
    vm2 = {
      hostname = "node-2"
    }
  }
}

variable "disks_per_instance" {
  type        = string
  description = ""
  default     = ""
}

provider "azurerm" {
  features {}
}

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.0.0"
    }
  }
}