# Terraform module for FortiGate Active/Passive High Availablity with Fabric Connector Failover

## Introduction

This example Terraform code illustrates how to deploy high availability FortiGate virtual machines pair with SDN connector in Active-Passive setup, using the module provided in the [modules directory](https://github.com/40net-cloud/terraform-azure-fortigate/tree/main/modules/active-passive-sdn).

The goal is to streamline the deployment process for users and offer a more efficient method for managing the associated resources.

The outcome of this deployment is similar to the deployment [here](https://github.com/fortinet/azure-templates/tree/main/FortiGate/Active-Passive-SDN). However, unlike the ARM template, there is no need to manually assign roles to the managed identity after deployment as it is handled automatically by the Terraform code.

## Deployment

### Overview

The Terraform code provisions a resource group that includes the following resources:

- Two FortiGate virtual machines, each configured with four network interfaces: external, internal, hasync, and mgmt. By default, FGT-a is active. 
- A virtual network (VNet) with four subnets: external, internal, hasync, and mgmt.
- Network Security Groups (NSGs) applied to the interfaces of each FortiGate VM.
- There Public IPs:
   - One public IP for cluster access, attached by default to the external interface of active FGT (used for inbound/outbound traffic through the active FortiGate).
   - One public IP for management access to FGT-a (attached to its mgmt interface).
   - One public IP for management access to FGT-b (attached to its mgmt interface).
- User Defined Routes (UDRs) with a default route pointing to the internal interface IP address of active FGT.
- Custom role assignment to the system-assigned managed identity of both FortiGates at the subscription level. This enables automated updates to UDR and public IP associations during failover. [Learn more here](https://docs.fortinet.com/document/fortigate-public-cloud/7.6.0/azure-administration-guide/430141/access-control)
- Reader role assignment to the system-assigned managed identity at the subscription scope. This allows the SDN connector to resolve private and/or public IP addresses using various Azure metadata properties, such as tags, VM names, NSGs, resource groups, and regions.  

***Post-deployment configuration steps***

- Configure an IPv4 outbound policy on the FortiGate VM from port2 (internal) to port1 (external). This is required for the SDN connector to resolve IP addresses.

- Attach your protected subnets (where your VM resources reside) to the UDR. This ensures that all traffic from your VMs is routed through the internal interface of the active FortiGate VM.

### Instructions

Follow these steps to deploy:

1. Navigate to the example directory (e.g., `examples/active-passive-sdn`).
2. Review variables defined in  `examples/active-passive-sdn/variables.tf` and ensure the all default values meet your requirements. Modify them as needed.
3. Rename the file `terraform.tfvars.txt` to `terraform.tfvars`.
4. Fill in the required variables in `terraform.tfvars` file.
5. Run the following commands:
<code><pre>
   terraform init
   terraform plan
   terraform apply
</code></pre>

## Support

Fortinet-provided scripts in this and other GitHub projects do not fall under the regular Fortinet technical support scope and are not supported by FortiCare Support Services.
For direct issues, please refer to the [Issues](https://github.com/40net-cloud/terraform-azure-fortigate/issues) tab of this GitHub project.

## License

[License](/../../blob/main/LICENSE) © Fortinet Technologies. All rights reserved.
