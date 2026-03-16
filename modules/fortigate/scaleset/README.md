## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3, < 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_http"></a> [http](#provider\_http) | n/a |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.app_insights](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_linux_function_app.function_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_linux_virtual_machine_scale_set.vmss](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | resource |
| [azurerm_log_analytics_workspace.log_analytics_workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_monitor_autoscale_setting.autoscale_setting](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_autoscale_setting) | resource |
| [azurerm_role_assignment.role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_service_plan.plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_storage_account.new_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_blob.fortigate_licenses](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob) | resource |
| [azurerm_storage_blob.function_blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob) | resource |
| [azurerm_storage_container.container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [null_resource.validate_image_version](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_string.random_function_app_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.random_storage_account_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_function_app_host_keys.function_app_keys](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/function_app_host_keys) | data source |
| [azurerm_storage_account.account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account) | data source |
| [azurerm_storage_account_sas.account_sas](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account_sas) | data source |
| [azurerm_virtual_machine_scale_set.vmss_instance](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_machine_scale_set) | data source |
| [http_http.function_health_check](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [local_file.fortinet_sku_to_versions_map_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_insights_id"></a> [application\_insights\_id](#input\_application\_insights\_id) | An ID of the Application Insights instance to use for providing metrics for autoscaling. | `string` | n/a | yes |
| <a name="input_autoscale_metrics"></a> [autoscale\_metrics](#input\_autoscale\_metrics) | Autoscale metrics for triggering scale-in or scale-out of the FortiGate VMSS.<br/>Options:<br/>- metric\_name                     (Required\|string) The autoscale metric name.<br/>- operator                        (Required\|string) Specifies the operator used to compare the metric data and threshold. Possible values are: Equals, NotEquals, GreaterThan, GreaterThanOrEqual, LessThan, LessThanOrEqual.<br/>- statistic                       (Required\|string) Specifies how the metrics from multiple instances are combined. Possible values are Average, Max, Min and Sum.<br/>- threshold                       (Required\|number) Specifies the threshold of the metric that triggers the scale action.<br/>- time\_aggregation                (Required\|string) Specifies how the data that's collected should be combined over time. Possible values include Average, Count, Maximum, Minimum, Last and Total.<br/>- time\_grain\_minutes              (Required\|number) Specifies the granularity of metrics that the rule monitors, which must be one of the pre-defined values returned from the metric definitions for the metric. This value must be between 1 minute and 12 hours.<br/>- time\_window\_minutes             (Required\|number) Specifies the time range for which data is collected, which must be greater than the delay in metric collection (which varies from resource to resource). This value must be between 5 minutes and 12 hours.<br/>- scale\_action\_direction          (Required\|string) The scale direction. Possible values are Increase and Decrease.<br/>- scale\_action\_type               (Required\|string) The type of action that should occur. Possible values are ChangeCount, ExactCount, PercentChangeCount and ServiceAllowedNextValue.<br/>- scale\_action\_value              (Required\|number) The number of instances involved in the scaling action.<br/>- scale\_action\_value              (Required\|number)<br/>- scale\_action\_cooldown\_minutes   (Required\|number) The amount of time to wait since the last scaling action before this action occurs. Must be between 1 minute and 1 week.<br/><br/>For more information, please visit https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_autoscale_setting<br/>https://learn.microsoft.com/en-us/azure/azure-monitor/reference/supported-metrics/microsoft-compute-virtualmachinescalesets-metrics<br/><br/>Example:<pre>autoscale_metrics = {<br/>  "Percentage CPU Scale Out" = {<br/>    metric_name                   = "Percentage CPU"<br/>    operator                      = "GreaterThanOrEqual"<br/>    statistic                     = "Average"<br/>    threshold                     = 80<br/>    time_aggregation              = "Last"<br/>    time_grain_minutes            = 1<br/>    time_window_minutes           = 5<br/>    scale_action_direction        = "Increase",<br/>    scale_action_type             = "ChangeCount",<br/>    scale_action_value            = 1<br/>    scale_action_cooldown_minutes = 120<br/>  }<br/>  "Percentage CPU Scale In" = {<br/>    metric_name                   = "Percentage CPU"<br/>    operator                      = "LessThanOrEqual"<br/>    statistic                     = "Average"<br/>    threshold                     = 80<br/>    time_aggregation              = "Last"<br/>    time_grain_minutes            = 1<br/>    time_window_minutes           = 5<br/>    scale_action_direction        = "Decrease",<br/>    scale_action_type             = "ChangeCount",<br/>    scale_action_value            = 1<br/>    scale_action_cooldown_minutes = 80<br/>  }<br/>}</pre> | `map(any)` | `{}` | no |
| <a name="input_autoscale_notification_emails"></a> [autoscale\_notification\_emails](#input\_autoscale\_notification\_emails) | Specifies a list of custom email addresses to which the autoscaling notifications will be sent. | `list(string)` | n/a | yes |
| <a name="input_azure_subscription_id"></a> [azure\_subscription\_id](#input\_azure\_subscription\_id) | The subscription ID associated with your Azure account. For more information, please visit [this Microsoft documentation](https://learn.microsoft.com/en-us/azure/azure-portal/get-subscription-tenant-id). | `string` | n/a | yes |
| <a name="input_data_type"></a> [data\_type](#input\_data\_type) | Use custom\_data or user\_data in vmss. | `string` | `"custom_data"` | no |
| <a name="input_default_count"></a> [default\_count](#input\_default\_count) | The minimum number of instances to keep in the scale set if the autoscaling engine cannot read the metrics or is unable to compare them to the thresholds. | `number` | n/a | yes |
| <a name="input_disk_encryption_set_id"></a> [disk\_encryption\_set\_id](#input\_disk\_encryption\_set\_id) | The ID of the Disk Encryption Set which should be used to encrypt this Data Disk. | `string` | `null` | no |
| <a name="input_enable_accelerated_networking"></a> [enable\_accelerated\_networking](#input\_enable\_accelerated\_networking) | If true, enable Azure accelerated networking (SR-IOV) for all dataplane network interfaces. | `bool` | n/a | yes |
| <a name="input_fmg_integration"></a> [fmg\_integration](#input\_fmg\_integration) | Using the User Managed Scaling feature in FortiManager to handle license management for FortiGate.<br/>Options for fmg\_integration:<br/>  - ip                  (Required\|string) The public IP address of the FortiManager.<br/>  - sn                  (Required\|string) The serial number of the FortiManager.<br/>  - ums                 (Optional\|object) The UMS (User Managed Scaling) configuration for FortiManager.<br/>    Options for ums:<br/>      - fmg\_register\_password        (Required\|string) The password used to access to your FortiManager.<br/>      - hb\_interval                  (Optional\|number) The interval in seconds between heartbeats sent from the FortiGate instances to the FortiManager. Default value is `30`.<br/>      - api\_key                      (Optional\|string) The API key for the FortiManager. This is required if you are using the FortiManager API to manage the FortiGate.<br/>Example:<pre>fmg_integration = {<br/>  ip                            = "13.82.216.180"<br/>  sn                            = "FGT123456789012345"<br/>  ums = {<br/>    fmg_register_password       = "fortinet"<br/>    hb_interval                 = 30<br/>    api_key                     = "example_api_user_key"<br/>  }<br/>}</pre> | <pre>object({<br/>    ip = string<br/>    sn = string<br/>    ums = optional(object({<br/>      fmg_register_password = string<br/>      hb_interval           = optional(number, 10)<br/>      api_key               = optional(string)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_fortiflex_api_password"></a> [fortiflex\_api\_password](#input\_fortiflex\_api\_password) | api password used for communicating with fortiflex for tokens | `string` | n/a | yes |
| <a name="input_fortiflex_api_username"></a> [fortiflex\_api\_username](#input\_fortiflex\_api\_username) | api user name used for communicating with fortiflex for tokens | `string` | n/a | yes |
| <a name="input_fortiflex_config_id"></a> [fortiflex\_config\_id](#input\_fortiflex\_config\_id) | IDs for the token pool derived from the configuration | `string` | n/a | yes |
| <a name="input_fortiflex_retrieve_mode"></a> [fortiflex\_retrieve\_mode](#input\_fortiflex\_retrieve\_mode) | mode to specify how fortiflex tokens are used, can be use\_active or use\_stopped, use\_stopped mode will use the fortiflex token with stopped status in your fortiflex account. | `string` | n/a | yes |
| <a name="input_fortigate_autoscale_psksecret"></a> [fortigate\_autoscale\_psksecret](#input\_fortigate\_autoscale\_psksecret) | secret used for configure fortigate auto-scale feature | `string` | n/a | yes |
| <a name="input_fortigate_custom_config"></a> [fortigate\_custom\_config](#input\_fortigate\_custom\_config) | the custom fortios configrations | `string` | `""` | no |
| <a name="input_fortigate_license_folder_path"></a> [fortigate\_license\_folder\_path](#input\_fortigate\_license\_folder\_path) | local path points to the folder of existing licenses. The licenses will be upload to the shared storage bucket. | `string` | n/a | yes |
| <a name="input_fortigate_license_source"></a> [fortigate\_license\_source](#input\_fortigate\_license\_source) | Either file, fortiflex or file\_fortiflex | `string` | `"file_fortiflex"` | no |
| <a name="input_fortigate_password"></a> [fortigate\_password](#input\_fortigate\_password) | Initial administrative password to use for Fortigate. | `string` | n/a | yes |
| <a name="input_fortigate_username"></a> [fortigate\_username](#input\_fortigate\_username) | Initial administrative username to use for Fortigate. | `string` | n/a | yes |
| <a name="input_image_sku"></a> [image\_sku](#input\_image\_sku) | FortiGate SKU – use the command `az vm image list -o table --all --publisher fortinet --offer fortinet_fortigate-vm` to see all the SKUs. | `string` | n/a | yes |
| <a name="input_image_version"></a> [image\_version](#input\_image\_version) | Fortigate version. | `string` | n/a | yes |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | Either `byol` or `payg`. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Region for installing FortiGate and its dependencies. | `string` | n/a | yes |
| <a name="input_max_count"></a> [max\_count](#input\_max\_count) | The maxmum number of instances to maintain in the scale set. | `number` | n/a | yes |
| <a name="input_min_count"></a> [min\_count](#input\_min\_count) | The minimum number of instances to maintain in the scale set. | `number` | n/a | yes |
| <a name="input_network_interfaces"></a> [network\_interfaces](#input\_network\_interfaces) | A list of the network interface specifications.<br/>Options:<br/>- name                     - (Required\|string) Interface name.<br/>- subnet\_id                - (Required\|string) Identifier of an existing subnet where the interface will be created.<br/>- create\_pip               - (Optional\|bool) If set to `true`, a public IP will be created for the interface.<br/>- lb\_backend\_pool\_ids      - (Optional\|list(string)) A list of identifiers for existing Load Balancer backend pools to associate with the interface.<br/>- gateway\_ip\_address       - (Required\|string) The IP address of the GWLB.<br/>- lb\_frontend\_ip\_address   - (Rquired\|string) THe GWLB frontend IP address.<br/><br/>Example:<pre>[<br/>  {<br/>    name      = "private"<br/>    subnet_id = "1234567"<br/>    create_pip = true<br/>  }<br/>]</pre> | <pre>list(object({<br/>    name                   = string<br/>    subnet_id              = string<br/>    create_pip             = optional(bool, false)<br/>    lb_backend_pool_ids    = optional(list(string), [])<br/>    gateway_ip_address     = string<br/>    lb_frontend_ip_address = optional(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_overprovision"></a> [overprovision](#input\_overprovision) | This means that multiple Virtual Machines will be provisioned and Azure will keep the instances which become available first - which improves provisioning success rates and improves deployment time. You're not billed for these over-provisioned VM's and they don't count towards the Subscription Quota | `bool` | `false` | no |
| <a name="input_platform_fault_domain_count"></a> [platform\_fault\_domain\_count](#input\_platform\_fault\_domain\_count) | Specifies the number of fault domains that are used by this Linux Virtual Machine Scale Set. Changing this forces a new resource to be created. | `number` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the Resource Group where the FortiGate vmss and the related resources will be placed. | `string` | n/a | yes |
| <a name="input_single_placement_group"></a> [single\_placement\_group](#input\_single\_placement\_group) | A flag for this Virtual Machine Scale Set be limited to a Single Placement Group, which means the number of instances will be capped at 100 Virtual Machines. | `bool` | `true` | no |
| <a name="input_storage_account_creation_flag"></a> [storage\_account\_creation\_flag](#input\_storage\_account\_creation\_flag) | Set to true to create a new storage account; set to false to use the existing one specified with `storage_account_name`. | `bool` | `true` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Name of the existing storage account where the function app artifacts will be stored. This is required if storage\_account\_creation\_flag is set false. | `string` | n/a | yes |
| <a name="input_storage_account_type"></a> [storage\_account\_type](#input\_storage\_account\_type) | The Type of Storage Account which should back this Data Disk. Possible values include Standard\_LRS, StandardSSD\_LRS, StandardSSD\_ZRS, Premium\_LRS, PremiumV2\_LRS, Premium\_ZRS and UltraSSD\_LRS. | `string` | `"StandardSSD_LRS"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the created resources. | `map(string)` | `{}` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Azure VM type to be created. | `string` | n/a | yes |
| <a name="input_vmss_name"></a> [vmss\_name](#input\_vmss\_name) | The name of the created scale set. | `string` | n/a | yes |
| <a name="input_zone_balance"></a> [zone\_balance](#input\_zone\_balance) | A flag for the Virtual Machines in this Scale Set be strictly evenly distributed across Availability Zones. | `bool` | `false` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Specifies a list of Availability Zones in which this Linux Virtual Machine Scale Set should be located. | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_image_sku"></a> [image\_sku](#output\_image\_sku) | Fortinet image SKU used by the VMSS |
| <a name="output_image_version"></a> [image\_version](#output\_image\_version) | Resolved Fortinet image version (mapped\_image\_version or image\_version) |
| <a name="output_scale_set_name"></a> [scale\_set\_name](#output\_scale\_set\_name) | The name of the created virtual machine scale set. |
