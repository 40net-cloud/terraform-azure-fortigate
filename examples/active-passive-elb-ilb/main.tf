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
module "vnet" {
  source              = "Azure/vnet/azurerm"
  version             = "4.1.0"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  use_for_each        = true
  address_space       = [var.vnet]
  subnet_prefixes     = var.subnets
  subnet_names        = ["${var.prefix}-subnet-external", "${var.prefix}-subnet-internal", "${var.prefix}-subnet-hasync", "${var.prefix}-subnet-hamgmt"]
  vnet_name           = "${var.prefix}-vnet"
  vnet_location       = var.location

  tags = var.fortinet_tags
}

##############################################################################################################
# Load Balancers
##############################################################################################################
module "elb" {
  source                       = "Azure/loadbalancer/azurerm"
  resource_group_name          = azurerm_resource_group.resourcegroup.name
  name                         = "${var.prefix}-externalloadbalancer"
  type = "public"
  lb_floating_ip_enabled       = true
  lb_probe_interval            = 5
  lb_probe_unhealthy_threshold = 2
  lb_sku                       = "Standard"
  pip_name                     = "jvh22-elb-pip"
  pip_sku                      = "Standard"

  lb_port = {
    http     = ["80", "Tcp", "80"]
    udp10551 = ["10551", "Udp", "10551"]
  }
  lb_probe = {
    lbprobe = ["Tcp", "8008", ""]
  }
  tags = var.fortinet_tags
  depends_on = [azurerm_resource_group.resourcegroup]
}

module "ilb" {
  source                       = "Azure/loadbalancer/azurerm"
  resource_group_name          = azurerm_resource_group.resourcegroup.name
  name                         = "${var.prefix}-internalloadbalancer"
  type = "private"
  lb_floating_ip_enabled       = true
  lb_probe_interval            = 5
  lb_probe_unhealthy_threshold = 2
  lb_sku                       = "Standard"
  frontend_subnet_id           = module.vnet.vnet_subnets_name_id["${var.prefix}-subnet-internal"]

  lb_port = {
    haports     = ["0", "All", "0"]
  }
  lb_probe = {
    lbprobe = ["Tcp", "8008", ""]
  }
  tags = var.fortinet_tags
  depends_on = [azurerm_resource_group.resourcegroup]
}

##############################################################################################################
# FortiGate Group
##############################################################################################################
module "fgt" {
  source = "../../modules/active-passive-elb-ilb"

  prefix                                          = var.prefix
  location                                        = var.location
  resource_group_name                             = azurerm_resource_group.resourcegroup.name
  username                                        = var.username
  password                                        = var.password
  virtual_network_name                            = module.vnet.vnet_name
  subnet_names                                    = keys(module.vnet.vnet_subnets_name_id)
  external_loadbalancer_name                      = "${var.prefix}-externalloadbalancer"
  external_loadbalancer_backend_address_pool_name = reverse(split("/", module.elb.azurerm_lb_backend_address_pool_id))[0]
  internal_loadbalancer_name                      = "${var.prefix}-internalloadbalancer"
  internal_loadbalancer_backend_address_pool_name = reverse(split("/", module.ilb.azurerm_lb_backend_address_pool_id))[0]
  fgt_image_sku                                   = var.fgt_image_sku
  fgt_version                                     = var.fgt_version
  fgt_byol_license_file_a                         = var.fgt_byol_license_file_a
  fgt_byol_license_file_b                         = var.fgt_byol_license_file_b
  fgt_byol_fortiflex_license_token_a              = var.fgt_byol_fortiflex_license_token_a
  fgt_byol_fortiflex_license_token_b              = var.fgt_byol_fortiflex_license_token_b
  fgt_accelerated_networking                      = var.fgt_accelerated_networking
  fgt_config_ha                                   = var.fgt_config_ha

  depends_on = [
    module.vnet,
    module.elb,
    module.ilb
  ]

}

##############################################################################################################
