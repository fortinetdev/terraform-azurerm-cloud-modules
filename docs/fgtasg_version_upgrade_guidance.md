### Upgrading FortiGate AutoScale Group
Upgrading the FortiGate image version in an Azure Virtual Machine Scale Set (VMSS) is supported. Please review the following considerations and steps to ensure a smooth upgrade process:

1. **Update the image version**
  Change the `image_version` value in the `fortigate_scaleset` section of your `terraform.tfvars` file. By default this will replace existing VMs: the old instances are deleted and new instances are created with the updated image.

  If you prefer to preserve the current instances and create a small number of new instances running the updated image (to validate configuration sync), follow these steps:

  1) Update the VMSS image reference remotely (optional). For example, with Azure PowerShell:

     Update-AzVmss -ResourceGroupName "autoscale-upgrade-test" -VMScaleSetName "vmss-byol" -ImageReferenceVersion 7.6.1

  2) Temporarily increase `min_count` and `default_count` in `terraform.tfvars` to create the additional test instances. For example, change `2, 2, 6` to `4, 4, 6` to add two instances.

2. **Apply the changes**
  1) Run `terraform apply` after updating `terraform.tfvars`. Terraform will create the additional instances with the new image while keeping the existing instances unchanged. Allow several minutes for the new instances to boot and synchronize configuration from the primary instance.

  2) To make the new instances the default members of the VMSS, scale in by lowering `min_count` and `default_count`. The VMSS scale-in policy is set to `OldestVM` by default, so the oldest instances will be removed and the newer instances (with the updated image) will remain. Change the scale-in policy if you need a different behavior.

4. **Review and Test**
  Before applying changes in a production environment, test the upgrade process in a staging environment to validate compatibility and minimize potential disruptions.

The Cloud Function is continuously updated to support new features and improvements. To benefit from these updates, you can upgrade the Cloud Function code using one of the following methods:

#### 1. If you are using a local copy of the project

If you have cloned or downloaded the source code locally (using `terraform.tfvars` file to deploy), you can manually update the Cloud Function code:

1. Download the latest [`cloud function code file`](https://github.com/fortinetdev/terraform-azurerm-cloud-modules/blob/main/modules/fortigate/scaleset/function_app.zip)
2. Replace the existing file at `/modules/fortigate/scaleset/function_app.zip`.
3. Re-run `terraform apply` to deploy the updated function.


#### 2. If you are using the project as a module

If you're using this project as a module, for example, by creating your own `main.tf` file and including the following block:

**Example (initial use without version pinning):**
```
module "applb_gwlb_fgtasg" {
  source = "fortinetdev/cloud-modules/azurerm//examples/applb_gwlb_fgtasg"

  # other parameters
}
```
Terraform will fetch the latest available version at the time of the first `terraform init`. However, this version is **locked** in your `.terraform.lock.hcl` file and will not automatically update, even if newer versions become available later.

To ensure you're using a specific version, or to upgrade to a newer one, you should explicitly specify the version attribute in your module block.

**To upgrade to a newer version:**

Update the `version` field to the desired version number. For example:

```
module "applb_gwlb_fgtasg" {
  source = "fortinetdev/cloud-modules/azurerm//examples/applb_gwlb_fgtasg"
  version = "1.0.3"  # <-- Update this to a new version

  # other parameters
}
```

Then run the following commands to upgrade and apply the changes:
```
terraform init -upgrade
terraform apply
```
