##############################################################################################################
#
# Fortinet FortiGate Terraform deployment
# Azure Virtual WAN NVA deployment
#
##############################################################################################################
# FortiGate
##############################################################################################################

resource "azurerm_user_assigned_identity" "managedidentity" {
  location            = var.location
  name                = "${var.prefix***REMOVED***-managed-identity"
  resource_group_name = var.resource_group_name
***REMOVED***

## Requires further cleanup to reduce the permissions
resource "azurerm_role_assignment" "contributor" {
  depends_on           = [azurerm_user_assigned_identity.managedidentity]
  scope                = var.subscription_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.managedidentity.principal_id
***REMOVED***

#resource "azurerm_role_assignment" "reader" {
#  depends_on           = [azurerm_user_assigned_identity.managedidentity]
#  scope                = var.subscription_id
#  role_definition_name = "Reader"
#  principal_id         = azurerm_user_assigned_identity.managedidentity.principal_id
#***REMOVED***

#resource "azurerm_role_assignment" "custom" {
#  depends_on           = [azurerm_user_assigned_identity.managedidentity]
#  scope                = var.subscription_id
#  role_definition_name = "Virtual WAN Administrator - ${var.prefix***REMOVED***"
#  principal_id         = azurerm_user_assigned_identity.managedidentity.principal_id
#***REMOVED***

#resource "azurerm_role_definition" "vwanadministrator" {
#  name  = "Virtual WAN Administrator - ${var.prefix***REMOVED***"
#  scope = var.subscription_id
#  permissions {
#    actions     = ["Microsoft.Network/virtualWans/*",
#                    "Microsoft.Network/virtualHubs/*",
#                    "Microsoft.Network/azureFirewalls/read",
#                    "Microsoft.Network/networkVirtualAppliances/*/read",
#                    "Microsoft.Network/securityPartnerProviders/*/read",
#                    "Microsoft.Network/expressRouteGateways/*",
#                    "Microsoft.Network/vpnGateways/*",
#                    "Microsoft.Network/p2sVpnGateways/*",
#                    "Microsoft.Network/virtualNetworks/peer/action"]
#    not_actions = []
#  ***REMOVED***
#  assignable_scopes = [var.subscription_id]
#***REMOVED***

resource "azapi_resource" "fgtinvhub" {
  type      = "Microsoft.Solutions/applications@2021-07-01"
  name      = var.name
  parent_id = var.resource_group_id
  location  = var.location
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.managedidentity.id
    ]
  ***REMOVED***
  body = {
    kind = "MarketPlace",
    plan = {
      name      = var.plan_name
      product   = var.product
      publisher = var.publisher
      version   = var.plan_version
    ***REMOVED***,
    properties = {
      managedResourceGroupId = "${var.subscription_id***REMOVED***/resourcegroups/${var.managed_resource_group_name***REMOVED***",
      parameters = {
        adminUsername = {
          value = var.username
        ***REMOVED***
        adminPassword = {
          value = var.password
        ***REMOVED***
        fortiGateNamePrefix = {
          value = var.prefix
        ***REMOVED***
        vwandeploymentSKU = {
          value = "${var.deployment_type***REMOVED***-${var.sku***REMOVED***"
        ***REMOVED***
        managedApplicationPlan = {
          value = var.plan_name
        ***REMOVED***
        vwandeploymentType = {
          value = var.deployment_type
        ***REMOVED***
        fortiGateImageVersion = {
          value = var.mpversion
        ***REMOVED***
        hubId = {
          value = var.vhub_id
        ***REMOVED***
        fortiGateASN = {
          value = tostring(var.asn)
        ***REMOVED***
        ***REMOVED***
          value = var.tags
        ***REMOVED***
        scaleUnit = {
          value = var.scaleunit
        ***REMOVED***
        hubRouters = {
          value = [
            var.vhub_virtual_router_ip1,
            var.vhub_virtual_router_ip2
          ]
        ***REMOVED***
        hubASN = {
          value = tostring(var.vhub_virtual_router_asn)
        ***REMOVED***
        location = {
          value = var.location
        ***REMOVED***
        fortiManagerIP = {
          value = var.fortimanager_host
        ***REMOVED***
        fortiManagerSerial = {
          value = var.fortimanager_serial
        ***REMOVED***
        internetInboundCheck = {
          value = var.internet_inbound_enabled
        ***REMOVED***
        slbpiprg = {
          value = var.internet_inbound_public_ip_rg
        ***REMOVED***
        slbpipname = {
          value = var.internet_inbound_public_ip_name
        ***REMOVED***
        slbPIpNewOrExisting = {
          value = "existing"
        ***REMOVED***
        slbpublicIpDns = {
          value = ""
        ***REMOVED***
        slbpublicIpSku = {
          value = "Standard"
        ***REMOVED***
      ***REMOVED***
    ***REMOVED***
  ***REMOVED***
***REMOVED***
##############################################################################################################
