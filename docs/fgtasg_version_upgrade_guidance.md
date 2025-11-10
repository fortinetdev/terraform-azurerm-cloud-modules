### Upgrading FortiGate AutoScale Group
Upgrading the FortiGate image version in an Azure Virtual Machine Scale Set (VMSS) is supported. Please review the following considerations and steps to ensure a smooth upgrade process:

1. **Update the Image Version**
  Modify the `image_version` parameter in the `fortigate_scaleset` section of your `terraform.tfvars` file. This change ensures that all newly launched VM instances will use the updated image version. Existing VM instances will continue to run the previous image version.

2. **Apply the Changes**
  After updating the `terraform.tfvars` file, run `terraform apply` to deploy the changes. Only new VM instances created after this update will use the new image version.

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
