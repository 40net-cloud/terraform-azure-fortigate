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

  name                            = each.key
  resource_group_name             = azurerm_resource_group.resourcegroup.name
  virtual_network_name            = azurerm_virtual_network.vnet.name
  address_prefixes                = each.value.cidr
  default_outbound_access_enabled = false

  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

##############################################################################################################
# Load Balancers
##############################################################################################################
resource "azurerm_public_ip" "elb_pip" {
  name                = "${var.prefix}-elb-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.fortinet_tags
}

resource "azurerm_lb" "elb" {
  name                = "${var.prefix}-externalloadbalancer"
  location            = var.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  sku                 = "Standard"
  tags                = var.fortinet_tags

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = azurerm_public_ip.elb_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "elb_pool" {
  name            = "${var.prefix}-externalloadbalancer-bepool"
  loadbalancer_id = azurerm_lb.elb.id
}

resource "azurerm_lb_probe" "elb_probe" {
  name                = "lbprobe"
  loadbalancer_id     = azurerm_lb.elb.id
  protocol            = "Tcp"
  port                = 8008
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "elb_http" {
  name                           = "http"
  loadbalancer_id                = azurerm_lb.elb.id
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.elb_pool.id]
  probe_id                       = azurerm_lb_probe.elb_probe.id
  floating_ip_enabled            = true
  idle_timeout_in_minutes        = 5
}

resource "azurerm_lb_rule" "elb_udp10551" {
  name                           = "udp10551"
  loadbalancer_id                = azurerm_lb.elb.id
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  protocol                       = "Udp"
  frontend_port                  = 10551
  backend_port                   = 10551
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.elb_pool.id]
  probe_id                       = azurerm_lb_probe.elb_probe.id
  floating_ip_enabled            = true
  idle_timeout_in_minutes        = 5
}

resource "azurerm_lb" "ilb" {
  name                = "${var.prefix}-internalloadbalancer"
  location            = var.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  sku                 = "Standard"
  tags                = var.fortinet_tags

  frontend_ip_configuration {
    name      = "LoadBalancerFrontEnd"
    subnet_id = azurerm_subnet.subnets["subnet-internal"].id
  }
}

resource "azurerm_lb_backend_address_pool" "ilb_pool" {
  name            = "${var.prefix}-internalloadbalancer-bepool"
  loadbalancer_id = azurerm_lb.ilb.id
}

resource "azurerm_lb_probe" "ilb_probe" {
  name                = "lbprobe"
  loadbalancer_id     = azurerm_lb.ilb.id
  protocol            = "Tcp"
  port                = 8008
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "ilb_haports" {
  name                           = "haports"
  loadbalancer_id                = azurerm_lb.ilb.id
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.ilb_pool.id]
  probe_id                       = azurerm_lb_probe.ilb_probe.id
  floating_ip_enabled            = true
  idle_timeout_in_minutes        = 5
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
# FortiGate
##############################################################################################################
module "fgt" {
  #  source = "github.com/40net-cloud/terraform-azure-fortigate/modules/active-passive"
  source = "../../modules/active-passive"

  prefix                             = var.prefix
  location                           = var.location
  resource_group_name                = azurerm_resource_group.resourcegroup.name
  username                           = var.username
  password                           = var.password
  virtual_network_id                 = azurerm_virtual_network.vnet.id
  virtual_network_address_space      = azurerm_virtual_network.vnet.address_space
  subnet_names                       = slice([for s in var.subnets : s.name], 0, 4)
  fgt_image_offer                    = var.fgt_image_offer
  fgt_image_sku                      = var.fgt_image_sku
  fgt_version                        = var.fgt_version
  fgt_vmsize                         = var.fgt_vmsize
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
