##############################################################################################################
#
# Fortinet FortiGate Terraform deployment 
# Azure Virtual WAN NVA deployment
#
##############################################################################################################
# Output of deployment
##############################################################################################################

output "fortigate-azurevirtualwan-managed_application" {
  value = azapi_resource.fgtinvhub
}

output "managed_resource_group_name" {
  value = var.managed_resource_group_name
}

output "nva_identity_id" {
  value = data.azapi_resource_list.fgtnva.output.value[0].identity.principalId
}

output "nva_id" {
  value = data.azapi_resource_list.fgtnva.output.value[0].id
}

output "nva_name" {
  value = data.azapi_resource_list.fgtnva.output.value[0].name
}

output "nva_prefix" {
  value = var.prefix
}

output "nva_instance_ids" {
  value = distinct(data.azapi_resource_list.fgtnva.output.value[0].properties.virtualApplianceNics[*].instanceName)
}

##############################################################################################################
