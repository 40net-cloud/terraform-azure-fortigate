##############################################################################################################
#
# FortiGate Active/Passive High Availability with Azure Standard Load Balancer - External and Internal
# Terraform deployment template for Microsoft Azure
#
##############################################################################################################
#
# Output of deployment
#
##############################################################################################################

output "fortigate-a-virtual-machine" {
  value = azurerm_linux_virtual_machine.fgtavm
}
output "fortigate-a-network-interface-external" {
  value = azurerm_network_interface.fgtaifcext
}
output "fortigate-a-network-interface-internal" {
  value = azurerm_network_interface.fgtaifcint
}
output "fortigate-a-network-interface-hasync" {
  value = azurerm_network_interface.fgtaifchasync
}
output "fortigate-a-network-interface-hamgmt" {
  value = azurerm_network_interface.fgtaifchamgmt
}
output "fortigate-b-virtual-machine" {
  value = azurerm_linux_virtual_machine.fgtbvm
}
output "fortigate-b-network-interface-external" {
  value = azurerm_network_interface.fgtbifcext
}
output "fortigate-b-network-interface-internal" {
  value = azurerm_network_interface.fgtbifcint
}
output "fortigate-b-network-interface-hasync" {
  value = azurerm_network_interface.fgtbifchasync
}
output "fortigate-b-network-interface-hamgmt" {
  value = azurerm_network_interface.fgtbifchamgmt
}
output "fortigate-network-security-group" {
  value = azurerm_network_security_group.fgtnsg
}

##############################################################################################################
