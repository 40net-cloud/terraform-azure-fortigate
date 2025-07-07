##############################################################################################################
#
# Standalone FortiGate VM
# Terraform deployment template for Microsoft Azure
#
##############################################################################################################
##############################################################################################################
# Resource Group
##############################################################################################################

resource "azurerm_resource_group" "resourcegroup" {
  name     = "${var.prefix}-rg"
  location = var.location
}

##############################################################################################################
# Virtual Network - VNET
##############################################################################################################
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = var.vnet
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
}

resource "azurerm_subnet" "subnets" {
  for_each = { for s in var.subnets : s.name => s }
  name                 = each.key
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.cidr
}

##############################################################################################################
# Public IP
##############################################################################################################
resource "azurerm_public_ip" "fgtpip" {
  name                = "${var.prefix}-fgt-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = format("%s-%s", lower(var.prefix), "fgt-pip")
}

##############################################################################################################
# FortiGate
##############################################################################################################
module "fgt" {
  #  source = "github.com/40net-cloud/terraform-azure-fortigate/modules/single"
  source = "../../modules/single"

  prefix                           = var.prefix
  location                         = var.location
  resource_group_name              = azurerm_resource_group.resourcegroup.name
  username                         = var.username
  password                         = var.password
  virtual_network_id               = azurerm_virtual_network.vnet.id
  subnet_names                     = slice([for s in var.subnets : s.name], 0, 2)
  fgt_image_sku                    = var.fgt_image_sku
  fgt_version                      = var.fgt_version
  fgt_byol_license_file            = var.fgt_byol_license_file
  fgt_byol_fortiflex_license_token = var.fgt_byol_fortiflex_license_token
  fgt_accelerated_networking       = var.fgt_accelerated_networking
  fgt_ip_configuration             = local.fgt_ip_configuration
  fgt_customdata_variables         = local.fgt_vars
  fgt_datadisk_size                = var.fgt_datadisk_size
  fgt_datadisk_count               = var.fgt_datadisk_count
}

##############################################################################################################
