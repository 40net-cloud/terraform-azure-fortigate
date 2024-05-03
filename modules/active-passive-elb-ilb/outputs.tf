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
***REMOVED***
output "fortigate-a-network-interface-external" {
  value = azurerm_network_interface.fgtaifcext
***REMOVED***
output "fortigate-a-network-interface-internal" {
  value = azurerm_network_interface.fgtaifcint
***REMOVED***
output "fortigate-a-network-interface-hasync" {
  value = azurerm_network_interface.fgtaifchasync
***REMOVED***
output "fortigate-a-network-interface-hamgmt" {
  value = azurerm_network_interface.fgtaifchamgmt
***REMOVED***
output "fortigate-b-virtual-machine" {
  value = azurerm_linux_virtual_machine.fgtbvm
***REMOVED***
output "fortigate-b-network-interface-external" {
  value = azurerm_network_interface.fgtbifcext
***REMOVED***
output "fortigate-b-network-interface-internal" {
  value = azurerm_network_interface.fgtbifcint
***REMOVED***
output "fortigate-b-network-interface-hasync" {
  value = azurerm_network_interface.fgtbifchasync
***REMOVED***
output "fortigate-b-network-interface-hamgmt" {
  value = azurerm_network_interface.fgtbifchamgmt
***REMOVED***
output "fortigate-network-security-group" {
  value = azurerm_network_security_group.fgtnsg
***REMOVED***

##############################################################################################################
