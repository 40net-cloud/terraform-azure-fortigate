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

  name                 = each.key
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.cidr
}

##############################################################################################################
# Load Balancers
##############################################################################################################

resource "azurerm_lb_nat_rule" "elbinboundrules" {
  for_each = merge({
    for i in range(var.fgt_count) :
    format("%s-fgt-%d-MGMT-SSH", var.prefix, i + 1) => {
      name           = format("%s-fgt-%d-MGMT-SSH", var.prefix, i + 1)
      protocol       = "Tcp"
      frontend_port  = 50030 + i
      backend_port   = 22
    }
  }, {
    for i in range(var.fgt_count) :
    format("%s-fgt-%d-MGMT-HTTPS", var.prefix, i + 1) => {
      name           = format("%s-fgt-%d-MGMT-HTTPS", var.prefix, i + 1)
      protocol       = "Tcp"
      frontend_port  = 40030 + i
      backend_port   = 443
    }
  })

  name                            = each.value.name
  resource_group_name             = azurerm_resource_group.resourcegroup.name
  loadbalancer_id                 = module.elb.azurerm_lb_id
  frontend_ip_configuration_name = module.elb.azurerm_lb_frontend_ip_configuration[0].name
  protocol                        = each.value.protocol
  frontend_port                   = each.value.frontend_port
  backend_port                    = each.value.backend_port
  enable_floating_ip              = false
  idle_timeout_in_minutes         = 4
  enable_tcp_reset                = false
}


resource "azurerm_network_interface_nat_rule_association" "nat_assoc" {
  for_each = merge({
    for idx in range(var.fgt_count) :
    format("%s-fgt-%d-MGMT-SSH", var.prefix, idx + 1) => {
      network_interface_id = module.fgt.fortigate_network_interface_external["node-${idx}"].id
      ip_config_name       = "ipconfig1"
      nat_rule_id          = azurerm_lb_nat_rule.elbinboundrules[format("%s-fgt-%d-MGMT-SSH", var.prefix, idx + 1)].id
    }
  }, {
    for idx in range(var.fgt_count) :
    format("%s-fgt-%d-MGMT-HTTPS", var.prefix, idx + 1) => {
      network_interface_id = module.fgt.fortigate_network_interface_external["node-${idx}"].id
      ip_config_name       = "ipconfig1"
      nat_rule_id          = azurerm_lb_nat_rule.elbinboundrules[format("%s-fgt-%d-MGMT-HTTPS", var.prefix, idx + 1)].id
    }
  })

  network_interface_id   = each.value.network_interface_id
  ip_configuration_name  = each.value.ip_config_name
  nat_rule_id            = each.value.nat_rule_id
  
  depends_on = [
    module.fgt,
    module.elb  
  ]
}

module "elb" {
  source                       = "Azure/loadbalancer/azurerm"
  resource_group_name          = azurerm_resource_group.resourcegroup.name
  name                         = "${var.prefix}-externalloadbalancer"
  type                         = "public"
  lb_floating_ip_enabled       = true
  lb_probe_interval            = 5
  lb_probe_unhealthy_threshold = 2
  lb_sku                       = "Standard"
  pip_name                     = "${var.prefix}-elb-pip"
  pip_sku                      = "Standard"

  lb_port = {
    http     = ["80", "Tcp", "80"]
    udp10551 = ["10551", "Udp", "10551"]
  }
  lb_probe = {
    lbprobe = ["Tcp", "8008", ""]
  }

  tags       = var.fortinet_tags
  depends_on = [azurerm_resource_group.resourcegroup]
}

module "ilb" {
  source                       = "Azure/loadbalancer/azurerm"
  resource_group_name          = azurerm_resource_group.resourcegroup.name
  name                         = "${var.prefix}-internalloadbalancer"
  type                         = "private"
  lb_floating_ip_enabled       = true
  lb_probe_interval            = 5
  lb_probe_unhealthy_threshold = 2
  lb_sku                       = "Standard"
  frontend_subnet_id           = azurerm_subnet.subnets["subnet-internal"].id

  lb_port = {
    haports = ["0", "All", "0"]
  }
  lb_probe = {
    lbprobe = ["Tcp", "8008", ""]
  }
  tags       = var.fortinet_tags
  depends_on = [azurerm_resource_group.resourcegroup]
}

##############################################################################################################
# FortiGate
##############################################################################################################

module "fgt" {
  source                             = "../../modules/active-active"
  prefix                             = var.prefix
  location                           = var.location
  resource_group_name                = azurerm_resource_group.resourcegroup.name
  username                           = var.username
  password                           = var.password
  virtual_network_id                 = azurerm_virtual_network.vnet.id
  virtual_network_address_space      = azurerm_virtual_network.vnet.address_space
  subnet_names                       = slice([for s in var.subnets : s.name], 0, 2)
  fgt_count                          = var.fgt_count
  fgt_image_sku                      = var.fgt_image_sku
  fgt_version                        = var.fgt_version
  fgt_accelerated_networking         = var.fgt_accelerated_networking
  fgt_ip_configuration               = local.fgt_ip_configuration
  fgt_availability_set               = var.fgt_availability_set
  fgt_availability_zone              = var.fgt_availability_zone
  fgt_datadisk_size                  = var.fgt_datadisk_size
  fgt_datadisk_count                 = var.fgt_datadisk_count
  fgt_serial_console                 = var.fgt_serial_console
  fortinet_tags                      = var.fortinet_tags
  fgt_customdata_variables           = local.fgt_vars
  subscription_id                    = var.subscription_id
}

##############################################################################################################
