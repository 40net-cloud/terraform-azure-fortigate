##############################################################################################################
#
# Standalone FortiGate VM
# Terraform deployment template for Microsoft Azure
#
##############################################################################################################
#
# Output of deployment
#
##############################################################################################################

output "fortigate-virtual-machine" {
  value = azurerm_linux_virtual_machine.fgtvm
}
output "fortigate-network-interface-external" {
  value = azurerm_network_interface.fgtifcext
}
output "fortigate-network-interface-internal" {
  value = azurerm_network_interface.fgtifcint
}

##############################################################################################################
