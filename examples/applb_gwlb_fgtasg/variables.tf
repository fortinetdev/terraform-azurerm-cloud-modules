variable "azure_subscription_id" {
  description = "The subscription ID associated with your Azure account. For more information, please visit [this Microsoft documentation](https://learn.microsoft.com/en-us/azure/azure-portal/get-subscription-tenant-id)."
  type        = string
}

variable "resource_group_creation_flag" {
  description = "Set to true to create a new resource group; set to false to use the existing resource group."
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "The name of the Resource Group to be created or used."
  type        = string
}

variable "location" {
  description = "The Azure Region where the resources exist."
  type        = string
}

# VNet Defination
variable "vnets" {
  description = <<-EOF
  Virtual Network Definition.
  Options:
  - create_virtual_network  - (Optional|bool) Whether to create a new or use an existing VNet, the default is `true`.
  - vnet_name               - (Required|string) VNet name used to identify a specific vnet.
  - resource_group_name     - (Optional|string) The Resource Group that the vnet belongs to.
  - address_space           - (Optional|list) A list of CIDRs for a new created VNet.
  - create_subnets          - (Optional|bool) Whether to create or use the exsiting subnets, the default is `true`.
  - subnets                 - (Required|map) Subnet definition.
  - network_security_groups - (Optional|map) NSG used for the vnet.

    Options for network_security_groups:
      - name                             - (Required|string) Network Security Group Name.
      - rules                            - (Optional|map) Rules for the NSG.

        Options for rules:
        - priority                       - (Required|number) Specifies the priority of the rule. The value can be between 100 and 4096.
        - direction                      - (Required|string) The direction specifies if rule will be evaluated on incoming or outgoing traffic. Possible values are `Inbound` and `Outbound`.
        - access                         - (Required|string) Specifies whether network traffic is allowed or denied. Possible values are `Allow` and `Deny`.
        - protocol                       - (Required|string) Network protocol this rule applies to. Possible values include Tcp, Udp, Icmp, Esp, Ah or * (which matches all).
        - source_address_prefix          - (Optional|string) CIDR or source IP range or * to match any IP.
        - source_address_prefixes        - (Optional|list)  List of source address prefixes. Tags may not be used. This is required if source_address_prefix is not specified.
        - source_port_range              - (Optional|string) Source Port or Range. Integer or range between 0 and 65535 or * to match any. This is required if source_port_ranges is not specified.
        - source_port_ranges             - (Optional|list) List of source ports or port ranges. This is required if source_port_range is not specified.
        - destination_address_prefix     - (Optional|string) CIDR or destination IP range or * to match any IP.
        - destination_address_prefixes   - (Optional|list) List of destination address prefixes.
        - destination_port_range         - (Optional|string) Destination Port or Range. Integer or range between 0 and 65535 or * to match any. This is required if destination_port_ranges is not specified.
        - destination_port_ranges        - (Optional|list) List of destination ports or port ranges. This is required if destination_port_range is not specified.

  Example:
  ```
  vnets = {
    security_vnet = {
      vnet_name = "your_vnet_name"
      resource_group_name = "your_resource_group_name"
      address_space = "192.168.1.0/24"
      subnets   = "192.168.1.0/25"
    }
  }
  ```

  EOF

  type = map(object({
    create_virtual_network = optional(bool, true)
    vnet_name              = string
    resource_group_name    = optional(string)
    address_space          = optional(list(string))
    create_subnets         = optional(bool, true)
    subnets                = map(any)
    network_security_groups = optional(map(object({
      name = string
      rules = map(object({
        priority                     = number
        direction                    = string
        access                       = string
        protocol                     = string
        source_address_prefix        = optional(string)
        source_address_prefixes      = optional(list(string))
        source_port_range            = optional(string)
        source_port_ranges           = optional(list(string))
        destination_address_prefix   = optional(string)
        destination_address_prefixes = optional(list(string))
        destination_port_range       = optional(string)
        destination_port_ranges      = optional(list(string))
      }))
    })), {})
  }))
}

# GWLB
variable "gateway_load_balancers" {
  description = <<-EOF
  Gateway Load Balancer definition.
  Options:
  - gwlb_name           - (Required|string) The name of the Gateway Load Balancer.
  - vnet_key            - (Required|string) Key of a VNet from `var.vnets` that contains target Subnet for GWLB's frontend. Used to get Subnet_id with `subnet_key`.
  - subnet_key          - (Required|string) Key of a Subnet from `var.vnets[vnet_key]`.
  - frontend_ip_config  - (Optional|map) Frontned IP configuration as Azure Gateway Load Balancer.
  - backend_pools       - (Optional|map) Backend configurations as Azure Gateway Load Balancer.
  - heatlh_probe        - (Optional|map) Health probe configuration as Azure Gateway Load Balancer.

  EOF

  type = map(object({
    gwlb_name          = string # Required
    vnet_key           = string # Required
    subnet_key         = string # Required
    frontend_ip_config = optional(map(any))
    backend_pools      = optional(map(any))
    health_probe       = optional(map(any))
  }))
}

variable "fortigate_scaleset" {
  description = <<-EOF
  FortiGate Virtual Machine Scale Set.
  Options:
  - vmss_name                                 (Required|string) The name of the FortiGate Scale Set.
  - image_version                        (Optional|string) Fortigate version.  The default value is `7.2.8`.
  - license_type                         (Optional|string) The options are `byol` and `payg`.
  - gen_type                             (Optional|string) The generation type for the FortiGate image. Possible values are `standard` and `g2`.
  - architecture                         (Optional|string) The architecture of the FortiGate image. Possible values are `x64` and `Arm64`.
  - vm_size                                (Required|string) The size of the Virtual Machine Scale Set instances.
  - zones                                (Optional|list(string)) Specifies a list of Availability Zones in which this Linux Virtual Machine Scale Set should be located.
  - vnet_key                             (Required|string) The VNET hosting the fortigate instances.
  - storage_account_name                 (Optional|string) The storage account that is used for the FortiGate Auto Scale set.
  - storage_account_creation_flag        (Optional|bool) Set to true to create a new storage account; set to false to use the existing one specified with `storage_account_name`. Default: true
  - application_insights_id              (Optional|string) An ID of the Application Insights instance to use for providing metrics for autoscaling.
  - network_interfaces                   (Required|list) Network interfaces for the FortiGate instances.
  - enable_accelerated_networking        (Optional|boolean) If true, enable Azure accelerated networking (SR-IOV) for all dataplane network interfaces.
  - fortigate_username                   (Required|string) The default is `fgtadmin`.
  - fortigate_password                   (Required|string) If the value is not provided, a generated string will be used for the password.
  - fortigate_license_folder_path        (Optional|string) The path for file-type licenses. If provided, the licenses will be uploaded; Otherwise, it assumes a FortiFlex token will be used.
  - fortiflex_api_username               (Optional|string) The username used to access to your Fortiflex account.
  - fortiflex_api_password               (Optional|string) The password used to access to your Fortiflex account.
  - fortiflex_config_id                  (Optional|string) The ID of the configuration for which to retrieve the list of VMs.
  - fortiflex_retrieve_mode              (Optional|string) mode to specify how fortiflex tokens are used, can be use_active or use_stopped, use_stopped mode will use the fortiflex token with stopped status in your fortiflex account.
  - autoscale_metrics                    (Required|map) The metrics used to automatically scale in/out FortiGate instances.
  - autoscale_notification_emails        (Optional|list) Specifies a list of custom email addresses to which the autoscaling notifications will be sent.
  - data_type                            (Optional|string) Use custom_data or user_data.
  - min_count                            (Optional|number) The minimum number of instances to maintain in the scale set. The default value is `1`.
  - default_count                        (Optional|number) The default number of instances to maintain in the scale set.
  The default value is `1`.
  - max_count                            (Optional|number) The maximum number of instances to maintain in the scale set.  The default value is `1`.
  - fmg_integration                      (Optional|object) Using the User Managed Scaling feature in FortiManager to handle license management for FortiGate.

  Options for fmg_integration:
    - ip                  (Required|string) The public IP address of the FortiManager.
    - sn                  (Required|string) The serial number of the FortiManager.
    - ums                 (Optional|object) The UMS (User Managed Scaling) configuration for FortiManager.
      Options for ums:
        - fmg_register_password        (Required|string) The password used to access to your FortiManager.
        - hb_interval                  (Optional|number) The interval in seconds between heartbeats sent from the FortiGate instances to the FortiManager. Default value is `30`.
        - api_key                      (Optional|string) The API key for the FortiManager. This is required if you are using the FortiManager API to manage the FortiGate.

  Options for autoscale_metrics:
    - metric_name                   (Required|string) The autoscale metric name.
    - operator                      (Required|string) Specifies the operator used to compare the metric data - and threshold. Possible values are: Equals, NotEquals, GreaterThan, GreaterThanOrEqual, LessThan, LessThanOrEqual.
    - statistic                     (Required|string) Specifies how the metrics from multiple instances are combined. Possible values are Average, Max, Min and Sum.
    - threshold                     (Required|string) Specifies the threshold of the metric that triggers the scale action.
    - time_aggregation              (Required|string) Specifies how the data that's collected should be combined over time. Possible values include Average, Count, Maximum, Minimum, Last and Total.
    - time_grain_minutes            (Required|number) Specifies the granularity of metrics that the rule monitors, which must be one of the pre-defined values returned from the metric definitions for the metric. This value must be between 1 minute and 12 hours.
    - time_window_minutes           (Required|number) Specifies the time range for which data is collected, which must be greater than the delay in metric collection (which varies from resource to resource). This value must be between 5 minutes and 12 hours.
    - scale_action_direction        (Required|string) The scale direction. Possible values are Increase and Decrease.
    - scale_action_type             (Required|string) The type of action that should occur. Possible values are ChangeCount, ExactCount, PercentChangeCount and ServiceAllowedNextValue.
    - scale_action_value            (Required|number) The number of instances involved in the scaling action.
    - scale_action_cooldown_minutes (Required|number) The amount of time to wait since the last scaling action before this action occurs. Must be between 1 minute and 1 week.
  }

EOF

  type = map(object({
    vmss_name                     = string
    storage_account_name          = optional(string)
    storage_account_creation_flag = optional(bool, true)
    zones                         = optional(list(string))
    vnet_key                      = string
    image_version                 = optional(string, "7.2.8")
    architecture                  = optional(string)
    license_type                  = optional(string)
    gen_type                      = optional(string)
    application_insights_id       = optional(string)
    network_interfaces = list(object({
      name                = string
      subnet_key          = string
      gateway_ip_address  = string
      create_public_ip    = optional(bool)   # Optional boolean
      enable_backend_pool = optional(bool)   # Optional boolean
      gwlb_key            = optional(string) # Optional string
      gwlb_backend_key    = optional(string) # Optional string
    }))
    enable_accelerated_networking = optional(bool)
    fortigate_username            = optional(string, "fgtadmin")
    fortigate_password            = optional(string)
    fortigate_license_folder_path = optional(string)
    fortiflex_api_username        = optional(string)
    fortiflex_api_password        = optional(string)
    fortiflex_config_id           = optional(string)
    fortiflex_retrieve_mode       = optional(string)
    vm_size                       = string
    autoscale_metrics = map(object({
      metric_name                   = string
      operator                      = string
      statistic                     = string
      threshold                     = string
      time_aggregation              = string
      time_grain_minutes            = number
      time_window_minutes           = number
      scale_action_direction        = string
      scale_action_type             = string
      scale_action_value            = number
      scale_action_cooldown_minutes = number
    }))
    autoscale_notification_emails = optional(list(string))
    min_count                     = optional(number, 1)
    default_count                 = optional(number, 1)
    max_count                     = optional(number, 1)
    fmg_integration = optional(object({
      ip = string
      sn = string
      ums = optional(object({
        fmg_register_password = string
        hb_interval           = optional(number, 30)
        api_key               = optional(string)
      }))
    }))
  }))
}

variable "standard_load_balancers" {
  description = <<-EOF
  Standard Load Balancer that is connected with the applications.
  Options:
  - lb_name                           - (Required|string) Name of the Load Balancer resource.
  - network_security_group_name       - (Optional|string) The name of a security group.
  - avzones                           - (Optional|list) For regional Load Balancers, a list of supported zones.
  - frontend_ips                      - (Optional|map) Map configuring both a listener and load balancing/outbound rules.

    Options for frontend_ips:
      - create_public_ip         - (Optional|bool) Set to `true` to create a Public IP. Default is `true`
      - public_ip_name           - (Optional|string) The public IP name to be created. Default value is `null`.
      - public_ip_resource_group - (Optional|string) when using an existing Public IP created in a different Resource Group than the currently used use this property is to provide the name of that RG. Default value is `null`.
      - private_ip_address       - (Optional|string) Specify a static IP address that will be used by a listener Default value is `null`.
      - vnet_key                 - (Optional|string) when `private_ip_address is set specifies a vnet_key, as defined in vnet variable. This will be the VNET hosting this Load Balancer. The default value is `null`.
      - subnet_key               - (Optional|string) when `private_ip_address is set specifies a subnet's key (as defined in `vnet variable) to which the LB will be attached, in case of FortiGate could be a internal/trust subnet. The default value is `null`.
      - inbound_rules                 - (Optional|map) Same as inbound rules for the Load Balancer.
      - outbound_rules                - (Optional|map) Same as outbound rules for the Load Balancer.
      For more information about the inbound and outbound rules, please visit https://registry.terraform.io/providers/hashicorp/azurerm/3.116.0/docs/resources/lb_rule

  Example:
  ```
  "public_lb" = {
    lb_name                           = "public_lb"
    network_security_group_name       = "http_nsg"
    avzones                           = ["1", "2"]
    frontend_ips = {
      "http_webserver" = {
        create_public_ip = true
        inbound_rules = {
          http = {
            enable_floating_ip = false
            port               = 80
            protocol           = "Tcp"
          }
        }
      }
    }
  }
  ```
  EOF
  type        = map(any)
}

variable "tags" {
  description = "Tags for the created resources."
  type        = map(string)
  default     = {}
}
