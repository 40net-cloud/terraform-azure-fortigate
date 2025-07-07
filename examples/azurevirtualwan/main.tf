##############################################################################################################
#
# Fortinet FortiGate Terraform deployment
# Azure Virtual WAN NVA deployment
#
##############################################################################################################
# Main
##############################################################################################################
resource "azurerm_resource_group" "resourcegroup" {
  name     = "${var.prefix}-rg"
  location = var.location

  tags = var.tags
}

##############################################################################################################
#
# Virtual WAN
#
##############################################################################################################

resource "azurerm_virtual_wan" "vwan" {
  name                = "${var.prefix}-virtualwan"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  location            = azurerm_resource_group.resourcegroup.location

  tags = var.tags
}

resource "azurerm_virtual_hub" "vhub" {
  name                = "${var.prefix}-virtualwan-hub"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  location            = azurerm_resource_group.resourcegroup.location
  virtual_wan_id      = azurerm_virtual_wan.vwan.id
  address_prefix      = var.vnet_vhub

  tags = var.tags
}

#resource "azurerm_virtual_hub_connection" "spoke1" {
#  name                      = "${var.prefix}-spoke1"
#  virtual_hub_id            = azurerm_virtual_hub.vhub.id
#  remote_virtual_network_id = azurerm_virtual_network.spoke1.id
#}

#resource "azurerm_virtual_hub_connection" "spoke2" {
#  name                      = "${var.prefix}-spoke2"
#  virtual_hub_id            = azurerm_virtual_hub.vhub.id
#  remote_virtual_network_id = azurerm_virtual_network.spoke2.id
#}

##############################################################################################################
# Inbound Public IP for FortiGate in Azure Virtual WAN
##############################################################################################################
resource "azurerm_public_ip" "elb-pip" {
  name                = "${var.prefix}-elb-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  allocation_method   = "Static"
  domain_name_label   = "${var.prefix}-elb-pip"
  sku                 = "Standard"
}

##############################################################################################################
#
# FortiGate
#
##############################################################################################################
module "fgt_nva" {
  #  source = "github.com/40net-cloud/terraform-azure-fortigate/modules/azurevirtualwan"
  source = "../../modules/azurevirtualwan"

  prefix   = var.prefix
  name     = "${var.prefix}-vwan-fgt"
  location = azurerm_resource_group.resourcegroup.location
  resource_group = {
    name = azurerm_resource_group.resourcegroup.name
    id   = azurerm_resource_group.resourcegroup.id
  }
  managed_resource_group_name = var.managed_resource_group_name
  subscription_id             = "/subscriptions/${var.subscription_id}"
  username                    = var.username
  password                    = var.password
  managedidentity_id          = var.managedidentity_id
  fgt_vwan_deployment_type    = var.fgt_vwan_deployment_type
  fgt_image_sku               = var.fgt_image_sku
  fgt_scaleunit               = var.fgt_scaleunit
  fgt_version                 = var.fgt_version
  fgt_asn                     = var.fgt_asn
  tags                        = var.tags
  fortimanager_host           = var.fortimanager_host
  fortimanager_serial         = var.fortimanager_serial
  vhub_id                     = azurerm_virtual_hub.vhub.id
  vhub_virtual_router_ip1     = azurerm_virtual_hub.vhub.virtual_router_ips[0]
  vhub_virtual_router_ip2     = azurerm_virtual_hub.vhub.virtual_router_ips[1]
  vhub_virtual_router_asn     = azurerm_virtual_hub.vhub.virtual_router_asn
  internet_inbound = {
    enabled        = true
    public_ip_rg   = azurerm_public_ip.elb-pip.resource_group_name
    public_ip_name = azurerm_public_ip.elb-pip.name
  }
}

##############################################################################################################
#
# Example: Spoke VNET with a VM in each spoke. Uncomment to use
#
##############################################################################################################

# resource "azurerm_virtual_network" "spoke1" {
#   name                = "${var.prefix}-spoke1-vnet"
#   address_space       = [var.vnet["spoke1"]]
#   location            = azurerm_resource_group.resourcegroup.location
#   resource_group_name = azurerm_resource_group.resourcegroup.name

#   tags = var.tags
# }

# resource "azurerm_subnet" "spoke1subnet1" {
#   name                 = "Subnet1"
#   resource_group_name  = azurerm_resource_group.resourcegroup.name
#   virtual_network_name = azurerm_virtual_network.spoke1.name
#   address_prefixes     = [var.spoke_subnet["spoke1"]]
# }

# resource "azurerm_virtual_hub_connection" "spoke1-connection1" {
#   name                      = "${var.prefix}-connection-spoke1-to-vwan-hub"
#   virtual_hub_id            = azurerm_virtual_hub.vhub.id
#   remote_virtual_network_id = azurerm_virtual_network.spoke1.id
# }

# resource "azurerm_virtual_network" "spoke2" {
#   name                = "${var.prefix}-spoke2-vnet"
#   address_space       = [var.vnet["spoke2"]]
#   location            = azurerm_resource_group.resourcegroup.location
#   resource_group_name = azurerm_resource_group.resourcegroup.name

#   tags = var.tags
# }

# resource "azurerm_subnet" "spoke2subnet1" {
#   name                 = "Subnet1"
#   resource_group_name  = azurerm_resource_group.resourcegroup.name
#   virtual_network_name = azurerm_virtual_network.spoke2.name
#   address_prefixes     = [var.spoke_subnet["spoke2"]]
# }

# resource "azurerm_virtual_hub_connection" "spoke2-connection1" {
#   name                      = "${var.prefix}-connection-spoke2-to-vwan-hub"
#   virtual_hub_id            = azurerm_virtual_hub.vhub.id
#   remote_virtual_network_id = azurerm_virtual_network.spoke2.id
# }


##############################################################################################################
#
# Example: Spoke VM
#
##############################################################################################################
# resource "azurerm_network_interface" "spoke1lnxifc" {
#  name                           = "${var.prefix}-spoke1-lnx-ifc"
#  location                       = azurerm_resource_group.resourcegroup.location
#  resource_group_name            = azurerm_resource_group.resourcegroup.name
#  ip_forwarding_enabled          = false
#  accelerated_networking_enabled = false

#  ip_configuration {
#    name                          = "interface1"
#    subnet_id                     = azurerm_subnet.spoke1subnet1.id
#    private_ip_address_allocation = "Dynamic"
#  }

#  tags = var.tags
# }

# resource "azurerm_linux_virtual_machine" "spoke1lnxvm" {
#  name                  = "${var.prefix}-spoke1-lnx"
#  location              = azurerm_resource_group.resourcegroup.location
#  resource_group_name   = azurerm_resource_group.resourcegroup.name
#  network_interface_ids = [azurerm_network_interface.spoke1lnxifc.id]
#  size                  = var.lnx_vmsize

#  source_image_reference {
#    publisher = "Canonical"
#    offer     = "0001-com-ubuntu-server-jammy"
#    sku       = "22_04-lts"
#    version   = "latest"
#  }

#  os_disk {
#    name                 = "${var.prefix}-spoke1-lnx-osdisk"
#    caching              = "ReadWrite"
#    storage_account_type = "StandardSSD_LRS"
#  }

#  computer_name                   = "${var.prefix}-spoke1-lnx"
#  admin_username                  = var.username
#  admin_password                  = var.password
#  disable_password_authentication = false
#  custom_data                     = base64encode(templatefile("${path.module}/vm-customdata.tftpl", {}))

#  boot_diagnostics {
#  }

#  tags = var.tags
# }

#resource "azurerm_network_interface" "spoke2lnxifc" {
#  name                           = "${var.prefix}-spoke2-lnx-ifc"
#  location                       = azurerm_resource_group.resourcegroup.location
#  resource_group_name            = azurerm_resource_group.resourcegroup.name
#  ip_forwarding_enabled          = false
#  accelerated_networking_enabled = false
#
#  ip_configuration {
#    name                          = "interface1"
#     subnet_id                     = azurerm_subnet.spoke2subnet1.id
#     private_ip_address_allocation = "Dynamic"
#   }
#
#   tags = var.tags
# }

# resource "azurerm_linux_virtual_machine" "spoke2lnxvm" {
#   name                  = "${var.prefix}-spoke2-lnx"
#   location              = azurerm_resource_group.resourcegroup.location
#   resource_group_name   = azurerm_resource_group.resourcegroup.name
#   network_interface_ids = [azurerm_network_interface.spoke2lnxifc.id]
#   size                  = var.lnx_vmsize

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "22_04-lts"
#     version   = "latest"
#   }

#   os_disk {
#     name                 = "${var.prefix}-spoke2-lnx-osdisk"
#     caching              = "ReadWrite"
#     storage_account_type = "StandardSSD_LRS"
#   }

#   computer_name                   = "${var.prefix}-spoke2-lnx"
#   admin_username                  = var.username
#   admin_password                  = var.password
#   disable_password_authentication = false
#   custom_data                     = base64encode(templatefile("${path.module}/vm-customdata.tftpl", {}))

#   boot_diagnostics {
#   }

#   tags = var.tags
# }

##############################################################################################################
#
# Example: Routing Intent
# Takes the first FortiGate deployment in the managed resource group. 
# Should only be adapted when using multiple FortiGate or NVA deployments.
#
##############################################################################################################
resource "azurerm_virtual_hub_routing_intent" "vwan_hub" {
  name           = "routing-intent"
  virtual_hub_id = azurerm_virtual_hub.vhub.id

  routing_policy {
    name         = "AllTrafficPolicy"
    destinations = ["Internet", "PrivateTraffic"]
    next_hop     = [for s in data.azapi_resource_list.listNVA.output.value : s if length(regexall(".*${var.prefix}-vwan-fgt.*", s.properties.cloudInitConfiguration)) > 0][0].id
  }
}

data "azurerm_resource_group" "managedresourcegroup" {
  name = var.managed_resource_group_name

  depends_on = [module.fgt_nva]
}

data "azapi_resource_list" "listNVA" {
  type                   = "Microsoft.Network/networkVirtualAppliances@2023-11-01"
  parent_id              = data.azurerm_resource_group.managedresourcegroup.id
  response_export_values = ["*"]

  depends_on = [module.fgt_nva]
}

#output "fortigate-azurevirtualwan-nva" {
#  value = [for s in data.azapi_resource_list.listNVA.output.value : s if length(regexall(".*${var.prefix}-vwan-fgt.*", s.properties.cloudInitConfiguration)) > 0][0].id
#}
