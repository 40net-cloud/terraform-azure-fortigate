# Terraform module for Standalone FortiGate VM

## Introduction

This example Terraform code illustrates how to deploy Standalone FortiGate VM, using the module provided in the [modules directory](https://github.com/40net-cloud/terraform-azure-fortigate/tree/main/modules/single).

The goal is to streamline the deployment process for users and offer a more efficient method for managing the associated resources.

The outcome of this deployment is similar to the deployment [here](https://github.com/fortinet/azure-templates/tree/main/FortiGate/A-Single-VM).

## Deployment

### Overview

The Terraform code provisions a resource group that includes the following resources:

- FortiGate virtual machine configured with two network interfaces: external, internal. 
- A virtual network (VNet) with two subnets: external, internal.
- Network Security Groups (NSGs) applied to FortiGate VM  interfaces.
- One public IP for management access to FGT-a (attached to external interface).

### Instructions

Follow these steps to deploy:

1. Navigate to the example directory (e.g., `examples/single`).
2. Review variables defined in  `examples/single/variables.tf` and ensure the all default values meet your requirements. Modify them as needed.
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
