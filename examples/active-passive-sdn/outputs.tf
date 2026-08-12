##############################################################################################################
#
# FortiGate Active/Passive High Availablity with Fabric Connector Failover
# Terraform deployment template for Microsoft Azure
#
##############################################################################################################
#
# Output of deployment
#
##############################################################################################################

output "fgt-vip" {
  value = azurerm_public_ip.fgt_pip.ip_address
}

output "fgta-mgmt-ip" {
  description = "Public IP address of the FortiGate A instance"
  value       = azurerm_public_ip.fgtamgmtpip.ip_address
}

output "fgtb-mgmt-ip" {
  description = "Public IP address of the FortiGate B instance"
  value       = azurerm_public_ip.fgtbmgmtpip.ip_address
}

output "fgta_private_ip_address" {
  description = "Private IP address of the FortiGate A instance - external"
  value       = module.fgt.fortigate-a-network-interface-external.private_ip_address
}

output "fgtb_private_ip_address" {
  description = "Private IP address of the FortiGate B instance - external"
  value       = module.fgt.fortigate-b-network-interface-external.private_ip_address
}

output "deployment_summary" {
  description = "Deployment information summary"
  value = templatefile("${path.module}/templates/summary.tftpl", {
    location                = var.location
    fgt_username            = var.username
    fgta_public_ip_address  = azurerm_public_ip.fgtamgmtpip.ip_address
    fgtb_public_ip_address  = azurerm_public_ip.fgtbmgmtpip.ip_address
    fgta_private_ip_address = module.fgt.fortigate-a-network-interface-external.private_ip_address
    fgtb_private_ip_address = module.fgt.fortigate-b-network-interface-external.private_ip_address
    vip_public_ip_address   = azurerm_public_ip.fgt_pip.ip_address
  })
}

##############################################################################################################
