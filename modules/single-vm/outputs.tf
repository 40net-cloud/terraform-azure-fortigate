##############################################################################################################
#
# FortiGate a standalone FortiGate VM
# Terraform deployment template for Microsoft Azure
#
##############################################################################################################
#
# Output summary of deployment
#
##############################################################################################################

data "azurerm_public_ip" "fgtpip" {
  name                = azurerm_public_ip.fgtpip.name
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_linux_virtual_machine.fgtvm]
}

output "deployment_summary" {
  value = templatefile("${path.module}/summary.tftpl", {
    username                        = var.username
    location                        = var.location
    fgt_private_ip_address_ext    = azurerm_network_interface.fgtifcext.private_ip_address
    fgt_private_ip_address_int    = azurerm_network_interface.fgtifcint.private_ip_address
    fgt_public_ip_address         = data.azurerm_public_ip.fgtpip.ip_address
  })
}

output "fgt_public_ip_address" {
  value = data.azurerm_public_ip.fgtpip.ip_address
}

##############################################################################################################
