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
  managed_resource_group_name = var.managed_resource_group_name != "" ? var.managed_resource_group_name : "${var.resource_group_name}-mrg"

  parameter_values = jsonencode({
    adminUsername = {
      value = var.username
    },
    adminPassword = {
      value = var.password
    },
    fortiGateNamePrefix = {
      value = var.prefix
    },
    vwandeploymentSKU = {
      value = "${var.deployment_type}-${var.sku}"
    }
    managedApplicationPlan = {
      value = "fortigate-managedvwan"
    }
    vwandeploymentType = {
      value = var.deployment_type
    }
    fortiGateImageVersion = {
      value = "7.4.5"
    },
    hubId = {
      value = var.vhub_id
    },
    fortiGateASN = {
      value = tostring(var.asn)
    },
    tags = {
      value = var.tags
    }
    scaleUnit = {
      value = var.scaleunit
    },
    hubRouters = {
      value = [var.vhub_virtual_router_ip1, var.vhub_virtual_router_ip2]
    },
    hubASN = {
      value = tostring(var.vhub_virtual_router_asn)
    },
    location = {
      value = var.location
    },
    fortiManagerIP = {
      value = var.fortimanager_host
    },
    fortiManagerSerial = {
      value = var.fortimanager_serial
    },
    internetInboundCheck = {
      value = var.internet_inbound_enabled
    },
    slbpiprg = {
      value = var.internet_inbound_public_ip_rg
    },
    slbpipname = {
      value = var.internet_inbound_public_ip_name
    },
    slbPIpNewOrExisting = {
      value = "existing"
    },
    slbpublicIpDns = {
      value = ""
    },
    slbpipAllocationMethod = {
      value = "Static"
    },
    slbpublicIpSku = {
      value = "Standard"
    }
  })
  plan {
    name      = "fortigate-managedvwan"
    product   = "fortigate_vwan_nva"
    publisher = "fortinet"
    version   = "7.4.500250218"
  }

  tags = var.tags
}

##############################################################################################################
