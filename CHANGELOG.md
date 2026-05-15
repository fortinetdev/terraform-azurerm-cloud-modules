## 1.0.7 (Unreleased)

## 1.0.6 (May 15, 2026)

IMPROVEMENTS:

* Added `validate_image_version` variable to allow users to skip image version validation when using marketplace versions not listed in the supported versions map. This enables support for deprecated versions in existing deployments.
* Added `sku` variable to the FortiGate scaleset module, allowing power users to provide a custom SKU directly instead of computing it from parameters. This approach automatically bypasses validation and supports image versions not yet in the supported versions map.
* Updated image version validation logic to support three approaches: validated parameter-based SKU (default), skipped validation with `validate_image_version = false`, or direct custom SKU with the `sku` parameter.
* Supported FOS v8.0.0 for FortiGate.
* Updated the terraform.tfvard.template files for the examples to support FortiGate v8.0.0.
* Used `precondition` in the `terraform_data` resource to address the command issue across different platforms.

## 1.0.5 (March. 13, 2026)
IMPROVEMENTS:

* Updated the documentation in fgtasg_version_upgrade_guidance.md;
* Updated the image SKU format logic to support the new SKUs and Offer;
* Updated main.tf under /modules/fortigate/scaleset/ to support the UMS feature;
* Updated the Azure Function;
* Added support for the UMS feature.
* Enabled Azure VM Serial Console in the Azure scaleset module.

## 1.0.4(Nov. 7, 2025)
IMPROVEMENTS:

* Enhanced the authentication logic to ensure compatibility with FortiOS 7.6.4 and newer versions.
* Introduced additional documentation to guide version upgrades within the autoscale group examples.

## 1.0.3 (May 30, 2025)
IMPROVEMENTS:

* Added the `generic_vm_standalone` module to support deployment of individual Fortinet products, including FortiGate, FortiManager, FortiAnalyzer, FortiGuest, and FortiAIOps.
* Updated the `azurerm_storage_container` resource to use the `storage_account_id` attribute for improved clarity and maintainability.
* Added a new parameter `vm_size` for greater flexibilty.
* Transitioned to using `connection_string` in the `application_insights` resource for better compatibility.
* Migrated to workspace-based Application Insights resources for improved monitoring and scalability.

BUGFIXES:

* Improved password handling by encoding the FortiGate password in URLs, allowing support for special characters.
* Made the flextoken variables optional for greater flexibility.

## 1.0.2 (March 5, 2025)

IMPROVEMENTS:

* Added a new module for deploying a single FortiGate instance on Azure.
* Add a new example, `extlb_fgtasg_intlb`, to demonstrate three-way traffic inspection, covering inbound, outbound, and east-west traffic flows.

## 1.0.1 (November 15, 2024)

BUGFIXES:

* Fixed an issue when modifying the VM instance count after deployment.
* Removed automatically generated files on certain OS systems, retaining only .lic files in the License folder.
* Resolved a bug in the reselect_master() function after upgrading to the latest Azure function dependencies.
* Enhanced the logic for the initial trigger of the Azure function to prevent timeout issues.

IMPROVEMENTS:

* Added support for both user_data and custom_data in VMSS.
* Introduced support for user-defined VXLAN tunnel ports and identifiers.
* Enabled support for user-defined ports in auto-scaling.
* Updated the supported FortOS versions for different license plans.

## 1.0.0 (Septem 9, 2024)

* Initial release