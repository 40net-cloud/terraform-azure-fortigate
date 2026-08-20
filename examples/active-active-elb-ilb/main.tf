##############################################################################################################
#
# FortiGate Active/Active High Availability with Azure Standard Load Balancer - External and Internal
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

resource "azurerm_lb_nat_rule" "elbinboundrules" {
  for_each = merge({
    for i in range(var.fgt_count) :
    format("%s-fgt-%d-MGMT-SSH", var.prefix, i) => {
      name          = format("%s-fgt-%d-MGMT-SSH", var.prefix, i)
      protocol      = "Tcp"
      frontend_port = 50030 + i
      backend_port  = 22
    }
    }, {
    for i in range(var.fgt_count) :
    format("%s-fgt-%d-MGMT-HTTPS", var.prefix, i) => {
      name          = format("%s-fgt-%d-MGMT-HTTPS", var.prefix, i)
      protocol      = "Tcp"
      frontend_port = 40030 + i
      backend_port  = 443
    }
  })

  name                           = each.value.name
  resource_group_name            = azurerm_resource_group.resourcegroup.name
  loadbalancer_id                = azurerm_lb.elb.id
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  floating_ip_enabled            = false
  idle_timeout_in_minutes        = 4
  tcp_reset_enabled              = false
}


resource "azurerm_network_interface_nat_rule_association" "nat_assoc" {
  for_each = merge({
    for idx in range(var.fgt_count) :
    format("%s-fgt-%d-MGMT-SSH", var.prefix, idx) => {
      network_interface_id = module.fgt.fortigate_network_interface_external["fgt-${idx}"].id
      ip_config_name       = "ipconfig1"
      nat_rule_id          = azurerm_lb_nat_rule.elbinboundrules[format("%s-fgt-%d-MGMT-SSH", var.prefix, idx)].id
    }
    }, {
    for idx in range(var.fgt_count) :
    format("%s-fgt-%d-MGMT-HTTPS", var.prefix, idx) => {
      network_interface_id = module.fgt.fortigate_network_interface_external["fgt-${idx}"].id
      ip_config_name       = "ipconfig1"
      nat_rule_id          = azurerm_lb_nat_rule.elbinboundrules[format("%s-fgt-%d-MGMT-HTTPS", var.prefix, idx)].id
    }
  })

  network_interface_id  = each.value.network_interface_id
  ip_configuration_name = each.value.ip_config_name
  nat_rule_id           = each.value.nat_rule_id

  depends_on = [
    module.fgt
  ]
}

resource "azurerm_public_ip" "elb_pip" {
  name                = "${var.prefix}-elb-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.fortinet_tags
}

resource "azurerm_lb" "elb" {
  name                = "${var.prefix}-elb"
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
  name            = "${var.prefix}-elb-bepool"
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
  name                = "${var.prefix}-ilb"
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
  name            = "${var.prefix}-ilb-bepool"
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
# FortiGate
##############################################################################################################

module "fgt" {
  source                        = "../../modules/active-active"
  prefix                        = var.prefix
  location                      = var.location
  resource_group_name           = azurerm_resource_group.resourcegroup.name
  username                      = var.username
  password                      = var.password
  virtual_network_id            = azurerm_virtual_network.vnet.id
  virtual_network_address_space = azurerm_virtual_network.vnet.address_space
  subnet_names                  = slice([for s in var.subnets : s.name], 0, 2)
  fgt_count                     = var.fgt_count
  fgt_vmsize                    = var.fgt_vmsize
  fgt_image_offer               = var.fgt_image_offer
  fgt_image_sku                 = var.fgt_image_sku
  fgt_version                   = var.fgt_version
  fgt_accelerated_networking    = var.fgt_accelerated_networking
  fgt_ip_configuration          = local.fgt_ip_configuration
  fgt_availability_set          = var.fgt_availability_set
  fgt_availability_zone         = var.fgt_availability_zone
  fgt_datadisk_size             = var.fgt_datadisk_size
  fgt_datadisk_count            = var.fgt_datadisk_count
  fgt_serial_console            = var.fgt_serial_console
  fortinet_tags                 = var.fortinet_tags
  fgt_customdata_variables      = local.fgt_vars
}

##############################################################################################################
