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

output "FGT-A-MGMT-IP" {
  value = azurerm_public_ip.fgtamgmtpip.ip_address
}

output "FGT-B-MGMT-IP" {
  value = azurerm_public_ip.fgtbmgmtpip.ip_address
}

##############################################################################################################
