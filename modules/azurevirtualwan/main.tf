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
  resource_group_name = var.resource_group.name
***REMOVED***

resource "azurerm_role_assignment" "reader" {
  depends_on           = [azurerm_user_assigned_identity.managedidentity]
  scope                = "${var.subscription_id***REMOVED***/resourceGroups/${var.resource_group.name***REMOVED***"
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.managedidentity.principal_id
***REMOVED***

resource "azurerm_role_definition" "joinpublicip" {
  name  = "${var.prefix***REMOVED*** - Public IP join role"
  scope = "${var.subscription_id***REMOVED***/resourceGroups/${var.internet_inbound.public_ip_rg***REMOVED***"
  permissions {
    actions     = ["Microsoft.Network/publicIPAddresses/join/action"]
    not_actions = []
  ***REMOVED***
  assignable_scopes = ["${var.subscription_id***REMOVED***/resourceGroups/${var.internet_inbound.public_ip_rg***REMOVED***"]
***REMOVED***

resource "azurerm_role_assignment" "joinpublicipassignment" {
  depends_on           = [azurerm_user_assigned_identity.managedidentity]
  scope                = "${var.subscription_id***REMOVED***/resourceGroups/${var.internet_inbound.public_ip_rg***REMOVED***"
  role_definition_name = azurerm_role_definition.joinpublicip.name
  principal_id         = azurerm_user_assigned_identity.managedidentity.principal_id
***REMOVED***

resource "azapi_resource" "fgtinvhub" {
  type      = "Microsoft.Solutions/applications@2021-07-01"
  name      = var.name
  parent_id = var.resource_group.id
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
      name      = var.plan.name
      product   = var.plan.product
      publisher = var.plan.publisher
      version   = var.plan.version
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
          value = "${var.fgt_vwan_deployment_type***REMOVED***-${var.fgt_image_sku***REMOVED***"
        ***REMOVED***
        managedApplicationPlan = {
          value = var.plan.name
        ***REMOVED***
        vwandeploymentType = {
          value = var.fgt_vwan_deployment_type
        ***REMOVED***
        fortiGateImageVersion = {
          value = var.fgt_version
        ***REMOVED***
        hubId = {
          value = var.vhub_id
        ***REMOVED***
        fortiGateASN = {
          value = tostring(var.fgt_asn)
        ***REMOVED***
        ***REMOVED***
          value = var.tags
        ***REMOVED***
        scaleUnit = {
          value = var.fgt_scaleunit
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
          value = var.internet_inbound.enabled
        ***REMOVED***
        slbpiprg = {
          value = var.internet_inbound.public_ip_rg
        ***REMOVED***
        slbpipname = {
          value = var.internet_inbound.public_ip_name
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
