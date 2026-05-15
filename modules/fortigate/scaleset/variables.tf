variable "azure_subscription_id" {
  description = "The subscription ID associated with your Azure account. For more information, please visit [this Microsoft documentation](https://learn.microsoft.com/en-us/azure/azure-portal/get-subscription-tenant-id)."
  type        = string
}

variable "location" {
  description = "Region for installing FortiGate and its dependencies."
  type        = string
}

variable "zones" {
  description = "Specifies a list of Availability Zones in which this Linux Virtual Machine Scale Set should be located."
  type        = list(string)
}

variable "resource_group_name" {
  description = "The name of the Resource Group where the FortiGate vmss and the related resources will be placed."
  type        = string
}

variable "vmss_name" {
  description = "The name of the created scale set."
  type        = string
}

variable "vm_size" {
  description = "Azure VM type to be created."
  type        = string
}

variable "data_type" {
  description = "Use custom_data or user_data in vmss."
  type        = string
  default     = "custom_data"
}

variable "storage_account_creation_flag" {
  description = "Set to true to create a new storage account; set to false to use the existing one specified with `storage_account_name`."
  type        = bool
  default     = true
}

variable "storage_account_name" {
  description = "Name of the existing storage account where the function app artifacts will be stored. This is required if storage_account_creation_flag is set false."
  type        = string
}

variable "storage_account_type" {
  description = "The Type of Storage Account which should back this Data Disk. Possible values include Standard_LRS, StandardSSD_LRS, StandardSSD_ZRS, Premium_LRS, PremiumV2_LRS, Premium_ZRS and UltraSSD_LRS."
  type        = string
  default     = "StandardSSD_LRS"
}

variable "enable_accelerated_networking" {
  description = "If true, enable Azure accelerated networking (SR-IOV) for all dataplane network interfaces."
  type        = bool
}

// License Type to create FortiGate-VM
// Provide the license type for FortiGate-VM Instances, either byol or payg.
variable "license_type" {
  description = "Either `byol` or `payg`."
  type        = string
}

variable "network_interfaces" {
  description = <<-EOF
  A list of the network interface specifications.
  Options:
  - name                     - (Required|string) Interface name.
  - subnet_id                - (Required|string) Identifier of an existing subnet where the interface will be created.
  - create_pip               - (Optional|bool) If set to `true`, a public IP will be created for the interface.
  - lb_backend_pool_ids      - (Optional|list(string)) A list of identifiers for existing Load Balancer backend pools to associate with the interface.
  - gateway_ip_address       - (Required|string) The IP address of the GWLB.
  - lb_frontend_ip_address   - (Rquired|string) THe GWLB frontend IP address.

  Example:
  ```
  [
    {
      name      = "private"
      subnet_id = "1234567"
      create_pip = true
    }
  ]
  ```
  EOF

  type = list(object({
    name                   = string
    subnet_id              = string
    create_pip             = optional(bool, false)
    lb_backend_pool_ids    = optional(list(string), [])
    gateway_ip_address     = string
    lb_frontend_ip_address = optional(string)
  }))
}

variable "fortigate_username" {
  description = "Initial administrative username to use for Fortigate."
  type        = string
}

variable "fortigate_password" {
  description = "Initial administrative password to use for Fortigate."
  type        = string
  sensitive   = true
}

variable "fortigate_license_folder_path" {
  description = "local path points to the folder of existing licenses. The licenses will be upload to the shared storage bucket."
  type        = string
}

variable "fortigate_license_source" {
  description = "Either file, fortiflex or file_fortiflex"
  type        = string
  default     = "file_fortiflex"
}

variable "fortigate_autoscale_psksecret" {
  description = "secret used for configure fortigate auto-scale feature "
  type        = string
}

variable "fortigate_custom_config" {
  description = "the custom fortios configrations"
  type        = string
  default     = ""
}

variable "fortiflex_api_username" {
  description = "api user name used for communicating with fortiflex for tokens"
  type        = string
}

variable "fortiflex_api_password" {
  description = "api password used for communicating with fortiflex for tokens"
  type        = string
  sensitive   = true
}

variable "fortiflex_config_id" {
  description = "IDs for the token pool derived from the configuration"
  type        = string
}

variable "fortiflex_retrieve_mode" {
  description = "mode to specify how fortiflex tokens are used, can be use_active or use_stopped, use_stopped mode will use the fortiflex token with stopped status in your fortiflex account."
  type        = string
}


variable "overprovision" {
  description = "This means that multiple Virtual Machines will be provisioned and Azure will keep the instances which become available first - which improves provisioning success rates and improves deployment time. You're not billed for these over-provisioned VM's and they don't count towards the Subscription Quota"
  type        = bool
  default     = false
}

variable "platform_fault_domain_count" {
  description = "Specifies the number of fault domains that are used by this Linux Virtual Machine Scale Set. Changing this forces a new resource to be created."
  type        = number
  default     = null
}

variable "single_placement_group" {
  description = "A flag for this Virtual Machine Scale Set be limited to a Single Placement Group, which means the number of instances will be capped at 100 Virtual Machines."
  type        = bool
  default     = true
}

variable "zone_balance" {
  description = "A flag for the Virtual Machines in this Scale Set be strictly evenly distributed across Availability Zones."
  type        = bool
  default     = false
}

variable "disk_encryption_set_id" {
  description = "The ID of the Disk Encryption Set which should be used to encrypt this Data Disk."
  type        = string
  default     = null
}

variable "image_sku" {
  description = "FortiGate SKU – use the command `az vm image list -o table --all --publisher fortinet --offer fortinet_fortigate-vm` to see all the SKUs. Avoid deploying 7.6.5, 7.4.10, 7.2.12, 7.0.18, and earlier versions due to known vulnerabilities."
  type        = string
}

variable "image_version" {
  description = "Fortigate version."
  type        = string
}

variable "sku" {
  description = "FortiGate SKU to use directly. If provided, this will be used instead of `image_sku` and validation against the fortinet_sku_to_versions_map.json will be automatically skipped. Use this to deploy image versions not yet in the supported versions map."
  type        = string
  default     = null
}

variable "application_insights_id" {
  description = "An ID of the Application Insights instance to use for providing metrics for autoscaling."
  type        = string
}

variable "autoscale_metrics" {
  description = <<-EOF
  Autoscale metrics for triggering scale-in or scale-out of the FortiGate VMSS.
  Options:
  - metric_name                     (Required|string) The autoscale metric name.
  - operator                        (Required|string) Specifies the operator used to compare the metric data and threshold. Possible values are: Equals, NotEquals, GreaterThan, GreaterThanOrEqual, LessThan, LessThanOrEqual.
  - statistic                       (Required|string) Specifies how the metrics from multiple instances are combined. Possible values are Average, Max, Min and Sum.
  - threshold                       (Required|number) Specifies the threshold of the metric that triggers the scale action.
  - time_aggregation                (Required|string) Specifies how the data that's collected should be combined over time. Possible values include Average, Count, Maximum, Minimum, Last and Total.
  - time_grain_minutes              (Required|number) Specifies the granularity of metrics that the rule monitors, which must be one of the pre-defined values returned from the metric definitions for the metric. This value must be between 1 minute and 12 hours.
  - time_window_minutes             (Required|number) Specifies the time range for which data is collected, which must be greater than the delay in metric collection (which varies from resource to resource). This value must be between 5 minutes and 12 hours.
  - scale_action_direction          (Required|string) The scale direction. Possible values are Increase and Decrease.
  - scale_action_type               (Required|string) The type of action that should occur. Possible values are ChangeCount, ExactCount, PercentChangeCount and ServiceAllowedNextValue.
  - scale_action_value              (Required|number) The number of instances involved in the scaling action.
  - scale_action_value              (Required|number)
  - scale_action_cooldown_minutes   (Required|number) The amount of time to wait since the last scaling action before this action occurs. Must be between 1 minute and 1 week.

  For more information, please visit https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_autoscale_setting
  https://learn.microsoft.com/en-us/azure/azure-monitor/reference/supported-metrics/microsoft-compute-virtualmachinescalesets-metrics

  Example:
  ```
  autoscale_metrics = {
    "Percentage CPU Scale Out" = {
      metric_name                   = "Percentage CPU"
      operator                      = "GreaterThanOrEqual"
      statistic                     = "Average"
      threshold                     = 80
      time_aggregation              = "Last"
      time_grain_minutes            = 1
      time_window_minutes           = 5
      scale_action_direction        = "Increase",
      scale_action_type             = "ChangeCount",
      scale_action_value            = 1
      scale_action_cooldown_minutes = 120
    }
    "Percentage CPU Scale In" = {
      metric_name                   = "Percentage CPU"
      operator                      = "LessThanOrEqual"
      statistic                     = "Average"
      threshold                     = 80
      time_aggregation              = "Last"
      time_grain_minutes            = 1
      time_window_minutes           = 5
      scale_action_direction        = "Decrease",
      scale_action_type             = "ChangeCount",
      scale_action_value            = 1
      scale_action_cooldown_minutes = 80
    }
  }
  ```
  EOF
  type        = map(any)
  default     = {}
}

variable "default_count" {
  description = "The minimum number of instances to keep in the scale set if the autoscaling engine cannot read the metrics or is unable to compare them to the thresholds."
  type        = number
}

variable "min_count" {
  description = "The minimum number of instances to maintain in the scale set."
  type        = number
}

variable "max_count" {
  description = "The maxmum number of instances to maintain in the scale set."
  type        = number
}

variable "autoscale_notification_emails" {
  description = "Specifies a list of custom email addresses to which the autoscaling notifications will be sent."
  type        = list(string)
}

variable "fmg_integration" {
  description = <<-EOF
  Using the User Managed Scaling feature in FortiManager to handle license management for FortiGate.
  Options for fmg_integration:
    - ip                  (Required|string) The public IP address of the FortiManager.
    - sn                  (Required|string) The serial number of the FortiManager.
    - ums                 (Optional|object) The UMS (User Managed Scaling) configuration for FortiManager.
      Options for ums:
        - fmg_register_password        (Required|string) The password used to access to your FortiManager.
        - hb_interval                  (Optional|number) The interval in seconds between heartbeats sent from the FortiGate instances to the FortiManager. Default value is `30`.
        - api_key                      (Optional|string) The API key for the FortiManager. This is required if you are using the FortiManager API to manage the FortiGate.
  Example:
  ```
  fmg_integration = {
    ip                            = "13.82.216.180"
    sn                            = "FGT123456789012345"
    ums = {
      fmg_register_password       = "fortinet"
      hb_interval                 = 30
      api_key                     = "example_api_user_key"
    }
  }
  ```
  EOF

  type = object({
    ip = string
    sn = string
    ums = optional(object({
      fmg_register_password = string
      hb_interval           = optional(number, 10)
      api_key               = optional(string)
    }))
  })
  default = null
}

variable "tags" {
  description = "Tags for the created resources."
  type        = map(string)
  default     = {}
}

variable "validate_image_version" {
  type        = bool
  default     = true
  description = "Whether to validate image_version against the bundled Fortinet SKU/version map."
}
