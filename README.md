# FortiGate Terraform modules for Microsoft Azure

## Introduction

Multiple examples for the different deployment methods in Microsoft Azure can be found in the examples directory. These examples are based on the same architectures used for the ARM templates more information can be found [here](https://github.com/40net-cloud/fortinet-azure-solutions/tree/main/FortiGate)

## Deployment

Before deploying the example, users should review the `examples/terraform.tfvars.txt` file to ensure all required values are provided and to adjust any settings to fit their specific project needs.

1. Navigate to the example folder (e.g., `examples/azurevirtualwan`).
2. Review the variables in the file and provide all the required values in it.
3. Rename the file `terraform.tfvars.txt` to `terraform.tfvars`.
4. Run the following commands:

   ```sh
   terraform init
   terraform apply
   ```

## Support

Fortinet-provided scripts in this and other GitHub projects do not fall under the regular Fortinet technical support scope and are not supported by FortiCare Support Services.
For direct issues, please refer to the [Issues](https://github.com/40net-cloud/terraform-azure-fortigate/issues) tab of this GitHub project.

## License

[License](/../../blob/main/LICENSE) © Fortinet Technologies. All rights reserved.
