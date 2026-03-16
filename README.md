Terraform Modules for Deploying FortiGate VMs on Azure

## Supported Examples ##
1. applb_gwlb_fgtasg
2. extlb_fgtasg_intlb

## Design ##

You can find the design diagram for the selected example in the docs directory.

## Before Deployment ##

Before deploying an example, users should review the `terraform.tfvars.template` file located in the target example directory, (e.g. `examples/terraform.tfvars.template`). This ensures that all required values (especially the values marked as "YOUR_OWN_VALUE") are provided and allows for adjustments to settings according to the specific needs of the project.

## How to use the example: ##

**Use as a remote module**

1. Navigate to the example folder (e.g., `examples/applb_gwlb_fgtasg`).
2. Review the variables in the target file and provide all the required values in it.
3. Rename the file `terraform.tfvars.template` to `terraform.tfvars`.
4. Run the following commands:

   ```sh
   terraform init
   terraform apply
   ```

## Question or Issue ##

Open an issue if you have any questions [open an issue](https://github.com/fortinetdev/terraform-azurerm-cloud-modules/issues)

## License ##

[License](./LICENSE) © Fortinet Technologies. All rights reserved.