##############################################################################################################
#
# FortiGate Active/Passive High Availablity with Fabric Connector Failover
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
# Public IP for management interface of the FortiGate
##############################################################################################################
resource "azurerm_public_ip" "fgtamgmtpip" {
  name                = "${var.prefix}-fgt-a-mgmt-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  allocation_method   = "Static"
  domain_name_label   = "${var.prefix}-fgt-a-mgmt-pip"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "fgtbmgmtpip" {
  name                = "${var.prefix}-fgt-b-mgmt-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  allocation_method   = "Static"
  domain_name_label   = "${var.prefix}-fgt-b-mgmt-pip"
  sku                 = "Standard"
}

##############################################################################################################
# Route Table
##############################################################################################################

resource "azurerm_route_table" "protected_subnet_rt" {
  name                = "${var.prefix}-routetable-protectedsubnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  tags = {
    publisher = "Fortinet"
    template  = "Active-Passive-SDN"
    provider  = "6EB3B02F-50E5-4A3E-8CB8-2E12925APSDN"
  }
}

resource "azurerm_route" "to_default" {
  name                   = "toDefault"
  resource_group_name    = azurerm_resource_group.resourcegroup.name
  route_table_name       = azurerm_route_table.protected_subnet_rt.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = local.fgt_a_vars.fgt_internal_ipaddr
}

##############################################################################################################
# FortiGate
##############################################################################################################
module "fgt" {
  #  source = "github.com/40net-cloud/terraform-azure-fortigate/modules/active-passive-sdn"
  source = "../../modules/active-passive-sdn"

  prefix                             = var.prefix
  location                           = var.location
  subscription_id                    = var.subscription_id
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
  fgt_availability_set               = var.fgt_availability_set
  fgt_datadisk_size                  = var.fgt_datadisk_size
  fgt_datadisk_count                 = var.fgt_datadisk_count

}

##############################################################################################################
