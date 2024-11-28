##############################################################################################################
#
# Fortinet FortiGate Terraform deployment
# Azure Virtual WAN NVA deployment
#
##############################################################################################################
# FortiGate
##############################################################################################################
resource "azurerm_managed_application" "fgtinvhub" {
  name                        = var.name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  kind                        = "MarketPlace"
  managed_resource_group_name = var.managed_resource_group_name != "" ? var.managed_resource_group_name : "${var.resource_group_name***REMOVED***-mrg"

  parameter_values = jsonencode({
    adminUsername = {
      value = var.username
    ***REMOVED***,
    adminPassword = {
      value = var.password
    ***REMOVED***,
    fortiGateNamePrefix = {
      value = var.prefix
    ***REMOVED***,
    vwandeploymentSKU = {
      value = "${var.deployment_type***REMOVED***-${var.sku***REMOVED***"
    ***REMOVED***
    managedApplicationPlan = {
      value = "fortigate-managedvwan"
    ***REMOVED***
    vwandeploymentType = {
      value = var.deployment_type
    ***REMOVED***
    fortiGateImageVersion = {
      value = "7.4.5"
    ***REMOVED***,
    hubId = {
      value = var.vhub_id
    ***REMOVED***,
    fortiGateASN = {
      value = tostring(var.asn)
    ***REMOVED***,
    ***REMOVED***
      value = var.tags
    ***REMOVED***
    scaleUnit = {
      value = var.scaleunit
    ***REMOVED***,
    hubRouters = {
      value = [var.vhub_virtual_router_ip1, var.vhub_virtual_router_ip2]
    ***REMOVED***,
    hubASN = {
      value = tostring(var.vhub_virtual_router_asn)
    ***REMOVED***,
    location = {
      value = var.location
    ***REMOVED***,
    fortiManagerIP = {
      value = var.fortimanager_host
    ***REMOVED***,
    fortiManagerSerial = {
      value = var.fortimanager_serial
    ***REMOVED***,
    internetInboundCheck = {
      value = var.internet_inbound_enabled
    ***REMOVED***,
    slbpiprg = {
      value = var.internet_inbound_public_ip_rg
    ***REMOVED***,
    slbpipname = {
      value = var.internet_inbound_public_ip_name
    ***REMOVED***,
    slbPIpNewOrExisting = {
      value = "existing"
    ***REMOVED***,
    slbpublicIpDns = {
      value = ""
    ***REMOVED***,
    slbpipAllocationMethod = {
      value = "Static"
    ***REMOVED***,
    slbpublicIpSku = {
      value = "Standard"
    ***REMOVED***
  ***REMOVED***)
  plan {
    name      = "fortigate-managedvwan"
    product   = "fortigate_vwan_nva"
    publisher = "fortinet"
    version   = "7.4.500241025"
  ***REMOVED***

  tags = var.tags
***REMOVED***

##############################################################################################################
