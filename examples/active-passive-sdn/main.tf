##############################################################################################################
#
# FortiGate Active/Passive High Availability with Azure Standard Load Balancer - External and Internal
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

resource "azurerm_public_ip" "fgt_pip" {
  name                = "${var.prefix}-fgt-pip"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  location            = azurerm_resource_group.resourcegroup.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

##############################################################################################################
# FortiGate
##############################################################################################################
module "fgt" {
  #  source = "github.com/40net-cloud/terraform-azure-fortigate/modules/active-passive-elb-ilb"
  source = "../../modules/active-passive-elb-ilb"

  prefix                             = var.prefix
  location                           = var.location
  resource_group_name                = azurerm_resource_group.resourcegroup.name
  username                           = var.username
  password                           = var.password
  virtual_network_id                 = azurerm_virtual_network.vnet.id
  virtual_network_address_space      = azurerm_virtual_network.vnet.address_space
  subnet_names                       = slice([for s in var.subnets : s.name], 0, 4)
  fgt_image_sku                      = var.fgt_image_sku
  fgt_version                        = var.fgt_version
  fgt_byol_license_file_a            = var.fgt_byol_license_file_a
  fgt_byol_license_file_b            = var.fgt_byol_license_file_b
  fgt_byol_fortiflex_license_token_a = var.fgt_byol_fortiflex_license_token_a
  fgt_byol_fortiflex_license_token_b = var.fgt_byol_fortiflex_license_token_b
  fgt_accelerated_networking         = var.fgt_accelerated_networking
  fgt_ip_configuration               = local.fgt_ip_configuration
  fgt_a_customdata_variables         = local.fgt_a_vars
  fgt_b_customdata_variables         = local.fgt_b_vars

  # Azure Availability Set - a change from set to zone or vice versa will result in a redeploy and loss of all data
  fgt_availability_set = true
  # Azure Availability Zone
  #  fgt_availability_set               = false
  #  fgt_availability_zone              = ["2", "1"]
}

##############################################################################################################
