##############################################################################################################
#
# FortiGate Active/Active with Azure Standard Load Balancer - External and Internal
# Terraform deployment template for Microsoft Azure
#
##############################################################################################################
#
# Output of deployment
#
# Management access to the FortiGate instances goes via the External Load Balancer public IP using
# inbound NAT rules: SSH on port 50030 + n, HTTPS on port 40030 + n (n = FortiGate instance number).
#
##############################################################################################################

output "ELB-PIP" {
  value = module.elb.azurerm_public_ip_address
}

##############################################################################################################
