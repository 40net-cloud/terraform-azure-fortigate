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
  resource_group_name = var.resource_group_name
}

## Requires further cleanup to reduce the permissions
resource "azurerm_role_assignment" "contributor" {
  depends_on           = [azurerm_user_assigned_identity.managedidentity]
  scope                = var.subscription_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.managedidentity.principal_id
}

#resource "azurerm_role_assignment" "reader" {
#  depends_on           = [azurerm_user_assigned_identity.managedidentity]
#  scope                = var.subscription_id
#  role_definition_name = "Reader"
#  principal_id         = azurerm_user_assigned_identity.managedidentity.principal_id
#}

#resource "azurerm_role_assignment" "custom" {
#  depends_on           = [azurerm_user_assigned_identity.managedidentity]
#  scope                = var.subscription_id
#  role_definition_name = "Virtual WAN Administrator - ${var.prefix}"
#  principal_id         = azurerm_user_assigned_identity.managedidentity.principal_id
#}

#resource "azurerm_role_definition" "vwanadministrator" {
#  name  = "Virtual WAN Administrator - ${var.prefix}"
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
#  }
#  assignable_scopes = [var.subscription_id]
#}

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
  }
  body = {
    kind = "MarketPlace",
    plan = {
      name      = var.plan_name
      product   = var.product
      publisher = var.publisher
      version   = var.plan_version
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
          value = "${var.deployment_type}-${var.sku}"
        }
        managedApplicationPlan = {
          value = var.plan_name
        }
        vwandeploymentType = {
          value = var.deployment_type
        }
        fortiGateImageVersion = {
          value = var.mpversion
        }
        hubId = {
          value = var.vhub_id
        }
        fortiGateASN = {
          value = tostring(var.asn)
        }
        tags = {
          value = var.tags
        }
        scaleUnit = {
          value = var.scaleunit
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
          value = var.internet_inbound_enabled
        }
        slbpiprg = {
          value = var.internet_inbound_public_ip_rg
        }
        slbpipname = {
          value = var.internet_inbound_public_ip_name
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
