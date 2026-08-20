# FortiGate Terraform module for FortiGate Active/Passive High Availability with Azure Standard Load Balancer - External and Internal

## Introduction

This example Terraform code illustrates how to deploy FortiGate virtual machines with both external and internal Azure Load Balancers in Active-Passive setup, using the module provided in the [modules directory](https://github.com/40net-cloud/terraform-azure-fortigate/tree/main/modules/active-passive).

The goal is to streamline the deployment process for users and offer a more efficient method for managing the associated resources.

The outcome of this deployment is similar to the deployment [here](https://github.com/fortinet/azure-templates/tree/main/FortiGate/Active-Passive-ELB-ILB).

## Deployment

### Overview

The Terraform code provisions a resource group that includes the following resources:

- Two FortiGates virtual machines, each configured with four network interfaces: external, internal, hasync and mgmt
- External Azure Standard Load Balancer
- Internal Azure Standard Load Balancer
- VNET with an external, internal, hasync and mgmt subnets
- NSG attached to interfaces for each FortiGate 
- Three Public IPs:
   - A Public IP address used as the frontend IP for the external load balancer
   - A Public IP address attached to FGT-a mgmt interface used for management
   - A Public IP address attached to FGT-b mgmt interface used for management

By default (`fgt_ha_port_mode = "4-NIC"`), hasync and mgmt are kept on separate interfaces and subnets, as described above. Setting `fgt_ha_port_mode = "3-NIC"` combines hasync and mgmt onto a single interface (port3, requires FortiOS 7.0.1 or later): the dedicated mgmt subnet is not deployed, and each FortiGate's management public IP is attached directly to port3's private IP instead of a dedicated port4 interface. This allows deployment on Azure instance types that only support 3 NICs.

### Instructions

Follow these steps to deploy:

1. Navigate to the example directory (e.g., `examples/active-passive-elb-ilb`).
2. Review variables defined in  `examples/active-passive-elb-ilb/variables.tf` and ensure the all default values meet your requirements. Modify them as needed.
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
