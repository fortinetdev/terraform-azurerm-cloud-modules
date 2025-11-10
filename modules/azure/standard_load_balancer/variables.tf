variable "resource_group_name" {
  description = "The name of the Resource Group where the related resources will be placed."
  type        = string
}

variable "location" {
  description = "The location for deploying the load balancer and its dependent resources"
  type        = string
}

variable "avzones" {
  description = "Availability zones for load balancer's Fronted IP configurations."
  type        = list(string)
  default     = []
}

variable "lb_name" {
  description = "The name of the load balancer."
  type        = string
}

variable "frontend_ips" {
  description = <<-EOF
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

      Options for inbound_rules:
        - protocol                  - (Required|string) Protocol used for communication, possible values are 'Tcp', 'Udp' or 'All'.
        - port                      - (Required|string) Communication port, this is both the front and the backend port.
        - backend_port              - (Optional|string) The backend port to forward traffic to the backend pool.
        - floating_ip_enabled        - (Optional|string) Enables floating IP for the rule. A "floating” IP is reassigned to a secondary server in case the primary server fails. The default value is `true`.
        - load_distribution         - (Optional|string) Specifies the load balancing distribution type to be used by the Load Balancer. Possible values are: `Default`, `SourceIP`, `SourceIPProtocol`. Defaults to `Default`.

      Options for outbound_rules:
        - protocol                  - (Optional|string) Protocol used for communication, possible values are 'Tcp', 'Udp' or 'All'. Possible values are `All`, `Tcp` and `Udp`.
        - allocated_outbound_ports  - (Optional|string) Number of ports allocated per instance. The default is `1024`.
        - tcp_reset_enabled          - (Optional|boolean) Is TCP Reset enabled for this Load Balancer Rule? The default is `False`.
        - idle_timeout_in_minutes   - (Optional|boolean) Specifies the idle timeout in minutes for TCP connections. Valid values are between 4 and 30 minutes.

      For more information, please visit https://registry.terraform.io/providers/hashicorp/azurerm/3.62.0/docs/resources/lb_rule

  Example
  ```
  frontend_ips = {
    webserver = {
      create_public_ip = true
      gwlb_key         = "gwlb"
      inbound_rules = {
        http = {
        floating_ip_enabled = false
        port               = 80
        protocol           = "Tcp"
        }
        https = {
          floating_ip_enabled = false
          port               = 443
          protocol           = "Tcp"
        }
      }
      outbound_rules = {
        outbound_tcp_rule = {
          protocol                 = "Tcp"
          allocated_outbound_ports = 1024
          idle_timeout_in_minutes  = 5
          port                     = "*"
        }
      }
    }
  }
  ```

  EOF
  type        = map(any)
}

variable "backend_pool_name" {
  description = "The name of the backend pool to be created."
  type        = string
  default     = "fortigate_backend"
}

variable "probe_name" {
  description = "The name of the load balancer probe."
  type        = string
  default     = "fgt_health_probe"
}

variable "probe_port" {
  description = "Health check port number of the load balancer probe."
  type        = string
  default     = "80"
}

variable "network_security_group_name" {
  description = "The name of the Network Security Group for attaching the rule."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags for the resources created."
  type        = map(string)
  default     = {}
}
