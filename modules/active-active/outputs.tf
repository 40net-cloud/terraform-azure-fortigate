##############################################################################################################
#
# FortiGate Active/Active High Availability with Azure Standard Load Balancer - External and Internal
# Terraform deployment template for Microsoft Azure
#
##############################################################################################################
#
# Output of deployment
#
##############################################################################################################

# Output each Fortigate VM
output "fortigate_virtual_machines" {
  value = {
    for key in keys(local.fgt_customdata) :
    key => azurerm_linux_virtual_machine.fgtvm[key]
  }
}

# Output each external network interface
output "fortigate_network_interface_external" {
  value = {
    for key in keys(local.fgt_customdata) :
    key => azurerm_network_interface.fgtifcext[key]
  }
}

# Output each internal network interface
output "fortigate_network_interface_internal" {
  value = {
    for key in keys(local.fgt_customdata) :
    key => azurerm_network_interface.fgtifcint[key]
  }
}

##############################################################################################################
