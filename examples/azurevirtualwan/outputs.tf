##############################################################################################################
#
# Fortinet FortiGate Terraform deployment 
# Azure Virtual WAN NVA deployment
#
##############################################################################################################
# Output of deployment
##############################################################################################################

output "fortigate-azurevirtualwan-managed_application" {
  value = module.fgt_nva.fortigate-azurevirtualwan-managed_application
}

##############################################################################################################
