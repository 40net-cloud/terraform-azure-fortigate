##############################################################################################################
#
# FortiGate Active/Passive High Availability with Azure Standard Load Balancer - External and Internal
# Terraform deployment template for Microsoft Azure
#
##############################################################################################################
#
# Output summary of deployment
#
##############################################################################################################

data "azurerm_public_ip" "fgtamgmtpip" {
  name                = azurerm_public_ip.fgtamgmtpip.name
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_linux_virtual_machine.fgtavm]
}

data "azurerm_public_ip" "fgtbmgmtpip" {
  name                = azurerm_public_ip.fgtbmgmtpip.name
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_linux_virtual_machine.fgtbvm]
}

output "deployment_summary" {
  value = templatefile("${path.module}/summary.tftpl", {
    username                        = var.username
    location                        = var.location
    elb_ipaddress                   = "data.azurerm_public_ip.elbpip.ip_address"
    fgt_a_private_ip_address_ext    = azurerm_network_interface.fgtaifcext.private_ip_address
    fgt_a_private_ip_address_int    = azurerm_network_interface.fgtaifcint.private_ip_address
    fgt_a_private_ip_address_hasync = azurerm_network_interface.fgtaifchasync.private_ip_address
    fgt_a_private_ip_address_mgmt   = azurerm_network_interface.fgtaifcmgmt.private_ip_address
    fgt_a_public_ip_address         = data.azurerm_public_ip.fgtamgmtpip.ip_address
    fgt_b_private_ip_address_ext    = azurerm_network_interface.fgtbifcext.private_ip_address
    fgt_b_private_ip_address_int    = azurerm_network_interface.fgtbifcint.private_ip_address
    fgt_b_private_ip_address_hasync = azurerm_network_interface.fgtbifchasync.private_ip_address
    fgt_b_private_ip_address_mgmt   = azurerm_network_interface.fgtbifcmgmt.private_ip_address
    fgt_b_public_ip_address         = data.azurerm_public_ip.fgtbmgmtpip.ip_address
  })
}

output "fgt_a_public_ip_address" {
  value = data.azurerm_public_ip.fgtamgmtpip.ip_address
}

output "fgt_b_public_ip_address" {
  value = data.azurerm_public_ip.fgtbmgmtpip.ip_address
}

#output "elb_public_ip_address" {
#  value = data.azurerm_public_ip.elbpip.ip_address
#}

##############################################################################################################
