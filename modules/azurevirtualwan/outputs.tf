##############################################################################################################
#
# Fortinet FortiGate Terraform deployment 
# Azure Virtual WAN NVA deployment
#
##############################################################################################################
# Output of deployment
##############################################################################################################

output "fortigate-azurevirtualwan-managed_application" {
  value = azurerm_managed_application.fgtinvhub
}

##############################################################################################################