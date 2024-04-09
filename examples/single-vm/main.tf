##############################################################################################################
#
# FortiGate a standalone FortiGate VM
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
module "vnet" {
  source              = "Azure/vnet/azurerm"
  version             = "4.1.0"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  use_for_each        = true
  address_space       = [var.vnet]
  subnet_prefixes     = var.subnets
  subnet_names        = ["${var.prefix}-subnet-external", "${var.prefix}-subnet-internal"]
  vnet_name           = "${var.prefix}-vnet"
  vnet_location       = var.location

  tags = var.fortinet_tags
}

##############################################################################################################
# FortiGate
##############################################################################################################
module "fgt" {
  source = "../../modules/single-vm"

  prefix                                          = var.prefix
  location                                        = var.location
  resource_group_name                             = azurerm_resource_group.resourcegroup.name
  username                                        = var.username
  password                                        = var.password
  virtual_network_name                            = module.vnet.vnet_name
  subnet_names                                    = keys(module.vnet.vnet_subnets_name_id)
  fgt_image_sku                                   = var.fgt_image_sku
  fgt_version                                     = var.fgt_version
  fgt_byol_license_file                         = var.fgt_byol_license_file
  fgt_byol_fortiflex_license_token              = var.fgt_byol_fortiflex_license_token
  fgt_accelerated_networking                      = var.fgt_accelerated_networking

  depends_on = [
    module.vnet
  ]

}

##############################################################################################################
