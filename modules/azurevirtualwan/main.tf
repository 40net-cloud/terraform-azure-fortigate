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
  name                = "${var.prefix}-managed-identity"
  resource_group_name = var.resource_group.name
}

resource "azurerm_role_assignment" "reader" {
  depends_on           = [azurerm_user_assigned_identity.managedidentity]
  scope                = "${var.subscription_id}/resourceGroups/${var.resource_group.name}"
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.managedidentity.principal_id
}

resource "azurerm_role_definition" "joinpublicip" {
  name  = "${var.prefix} - Public IP join role"
  scope = "${var.subscription_id}/resourceGroups/${var.internet_inbound.public_ip_rg}"
  permissions {
    actions     = ["Microsoft.Network/publicIPAddresses/join/action"]
    not_actions = []
  }
  assignable_scopes = ["${var.subscription_id}/resourceGroups/${var.internet_inbound.public_ip_rg}"]
}

resource "azurerm_role_assignment" "joinpublicipassignment" {
  depends_on           = [azurerm_user_assigned_identity.managedidentity]
  scope                = "${var.subscription_id}/resourceGroups/${var.internet_inbound.public_ip_rg}"
  role_definition_name = azurerm_role_definition.joinpublicip.name
  principal_id         = azurerm_user_assigned_identity.managedidentity.principal_id
}

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
  }
  body = {
    kind = "MarketPlace",
    plan = {
      name      = var.plan.name
      product   = var.plan.product
      publisher = var.plan.publisher
      version   = var.plan.version
    },
    properties = {
      managedResourceGroupId = "${var.subscription_id}/resourcegroups/${var.managed_resource_group_name}",
      parameters = {
        adminUsername = {
          value = var.username
        }
        adminPassword = {
          value = var.password
        }
        fortiGateNamePrefix = {
          value = var.prefix
        }
        vwandeploymentSKU = {
          value = "${var.fgt_vwan_deployment_type}-${var.fgt_image_sku}"
        }
        managedApplicationPlan = {
          value = var.plan.name
        }
        vwandeploymentType = {
          value = var.fgt_vwan_deployment_type
        }
        fortiGateImageVersion = {
          value = var.fgt_version
        }
        hubId = {
          value = var.vhub_id
        }
        fortiGateASN = {
          value = tostring(var.fgt_asn)
        }
        tags = {
          value = var.tags
        }
        scaleUnit = {
          value = var.fgt_scaleunit
        }
        hubRouters = {
          value = [
            var.vhub_virtual_router_ip1,
            var.vhub_virtual_router_ip2
          ]
        }
        hubASN = {
          value = tostring(var.vhub_virtual_router_asn)
        }
        location = {
          value = var.location
        }
        fortiManagerIP = {
          value = var.fortimanager_host
        }
        fortiManagerSerial = {
          value = var.fortimanager_serial
        }
        internetInboundCheck = {
          value = var.internet_inbound.enabled
        }
        slbpiprg = {
          value = var.internet_inbound.public_ip_rg
        }
        slbpipname = {
          value = var.internet_inbound.public_ip_name
        }
        slbPIpNewOrExisting = {
          value = "existing"
        }
        slbpublicIpDns = {
          value = ""
        }
        slbpublicIpSku = {
          value = "Standard"
        }
      }
    }
  }
}
##############################################################################################################
