locals {
  handle_scale_event_endpoint = format(
    "https://%s/api/handle_auto_scale_events?code=%s",
    azurerm_linux_function_app.function_app.default_hostname,
    data.azurerm_function_app_host_keys.function_app_keys.default_function_key
  )
  fortinet_sku_to_versions_map = jsondecode(data.local_file.fortinet_sku_to_versions_map_file.content)
  image_version_valid          = contains(local.fortinet_sku_to_versions_map[var.image_sku], var.image_version)

  # Interface details
  public_interface_names                 = [for nic in var.network_interfaces : nic.name if try(nic.create_pip, false)]
  public_interface_gateway_ip_addresses  = [for nic in var.network_interfaces : nic.gateway_ip_address if try(nic.create_pip, false)]
  private_interface_names                = [for nic in var.network_interfaces : nic.name if !try(nic.create_pip)]
  private_interface_gateway_ip_addresses = [for nic in var.network_interfaces : nic.gateway_ip_address if !try(nic.create_pip, false)]
  lb_frontend_ip_addresses               = [for nic in var.network_interfaces : nic.lb_frontend_ip_address if nic.lb_frontend_ip_address != null && nic.lb_frontend_ip_address != ""]

  scale_set_config_data = templatefile("${path.module}/bootstrap_fgt.tpl", {
    public_interface_name                = length(local.public_interface_names) == 1 ? local.public_interface_names[0] : ""
    public_interface_gateway_ip_address  = length(local.public_interface_gateway_ip_addresses) == 1 ? local.public_interface_gateway_ip_addresses[0] : ""
    private_interface_name               = length(local.private_interface_names) == 1 ? local.private_interface_names[0] : ""
    private_interface_gateway_ip_address = length(local.private_interface_gateway_ip_addresses) == 1 ? local.private_interface_gateway_ip_addresses[0] : ""
    gwlb_frontend_ip_address             = length(local.lb_frontend_ip_addresses) == 1 ? local.lb_frontend_ip_addresses[0] : ""
    custom_config                        = var.fortigate_custom_config
    license_type                         = var.license_type
    fmg_integration                      = var.fmg_integration
  })
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                            = var.vmss_name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  admin_username                  = var.fortigate_username
  admin_password                  = var.fortigate_password
  disable_password_authentication = false # must be set to false if password is provided. As we use username & password to login.
  overprovision                   = var.overprovision
  platform_fault_domain_count     = var.platform_fault_domain_count
  single_placement_group          = var.single_placement_group
  instances                       = var.default_count
  sku                             = var.vm_size
  zones                           = var.zones
  zone_balance                    = var.zone_balance
  tags                            = var.tags

  lifecycle {
    precondition {
      condition     = var.fortigate_password != null && length(var.fortigate_password) >= 10
      error_message = "You need to set a password to access the device."
    }
  }

  custom_data = var.data_type == "custom_data" ? base64encode(local.scale_set_config_data) : null
  user_data   = var.data_type == "user_data" ? base64encode(local.scale_set_config_data) : null

  dynamic "network_interface" {
    for_each = var.network_interfaces
    iterator = nic
    content {
      name                          = "${var.vmss_name}-${nic.value.name}"
      primary                       = nic.key == 0
      enable_ip_forwarding          = nic.key != 0
      enable_accelerated_networking = nic.key != 0 ? var.enable_accelerated_networking : false

      ip_configuration {
        name                                   = "primary_ip"
        primary                                = true
        subnet_id                              = nic.value.subnet_id
        load_balancer_backend_address_pool_ids = try(nic.value.lb_backend_pool_ids, [])

        dynamic "public_ip_address" {
          for_each = try(nic.value.create_pip, false) ? [1] : []
          iterator = pip

          content {
            name = "${var.vmss_name}-${nic.value.name}-pip"
          }
        }
      }
    }
  }

  os_disk {
    caching                = "ReadWrite"
    disk_encryption_set_id = var.disk_encryption_set_id
    storage_account_type   = var.storage_account_type
  }

  source_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortigate-vm_v5"
    sku       = var.image_sku
    version   = var.image_version
  }

  plan {
    name      = var.image_sku
    publisher = "fortinet"
    product   = "fortinet_fortigate-vm_v5"
  }

  depends_on = [null_resource.validate_image_version]
}

resource "azurerm_monitor_autoscale_setting" "autoscale_setting" {
  count               = length(var.autoscale_metrics) > 0 ? 1 : 0
  name                = "${var.vmss_name}-autoscale-setting"
  location            = var.location
  resource_group_name = var.resource_group_name
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.vmss.id

  profile {
    name = "AutoscaleInstanceCount"
    capacity {
      default = var.default_count
      minimum = var.min_count
      maximum = var.max_count
    }

    dynamic "rule" {
      for_each = var.autoscale_metrics
      content {
        metric_trigger {
          metric_name        = rule.value.metric_name
          metric_resource_id = try(rule.value.metric_resource_id, azurerm_linux_virtual_machine_scale_set.vmss.id)
          operator           = rule.value.operator
          threshold          = rule.value.threshold
          statistic          = rule.value.statistic
          time_aggregation   = rule.value.time_aggregation
          time_grain         = "PT${rule.value.time_grain_minutes}M"
          time_window        = "PT${rule.value.time_window_minutes}M"
        }

        scale_action {
          direction = rule.value.scale_action_direction
          value     = rule.value.scale_action_value
          type      = rule.value.scale_action_type
          cooldown  = "PT${rule.value.scale_action_cooldown_minutes}M"
        }
      }
    }
  }

  notification {
    email {
      custom_emails = var.autoscale_notification_emails
    }
    webhook {
      service_uri = local.handle_scale_event_endpoint
    }
  }

  tags = var.tags
}

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = "${var.vmss_name}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.tags
}

resource "azurerm_application_insights" "app_insights" {
  name                = "${var.vmss_name}-appinsights"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.log_analytics_workspace.id
  application_type    = "web"
}

resource "random_string" "random_storage_account_name" {
  count   = var.storage_account_creation_flag ? 1 : 0
  length  = 10
  upper   = false
  special = false
}

# Create a new storage account if none is provided
resource "azurerm_storage_account" "new_account" {
  count                    = var.storage_account_creation_flag ? 1 : 0
  name                     = "fgtvmss${random_string.random_storage_account_name[0].result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

data "azurerm_storage_account" "account" {
  resource_group_name = var.resource_group_name
  name                = var.storage_account_creation_flag ? azurerm_storage_account.new_account[0].name : var.storage_account_name
  depends_on          = [azurerm_storage_account.new_account]
}

data "azurerm_storage_account_sas" "account_sas" {
  connection_string = data.azurerm_storage_account.account.primary_connection_string
  https_only        = true
  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = timestamp()
  expiry = timeadd(timestamp(), "168h")

  permissions {
    read    = true
    write   = true
    delete  = false
    list    = true
    add     = true
    create  = true
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}


# App Service: Service Plan.
resource "azurerm_service_plan" "plan" {
  name                = "${var.vmss_name}-appserviceplan"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "EP1"
}

resource "random_string" "random_function_app_name" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_linux_function_app" "function_app" {
  name                       = "${var.vmss_name}-func-${random_string.random_function_app_name.result}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  service_plan_id            = azurerm_service_plan.plan.id
  storage_account_name       = data.azurerm_storage_account.account.name
  storage_account_access_key = data.azurerm_storage_account.account.primary_access_key

  site_config {
    application_stack {
      python_version = "3.12"
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  app_settings = {
    "AzureWebJobsStorage"                   = data.azurerm_storage_account.account.primary_blob_connection_string
    "WEBSITE_RUN_FROM_PACKAGE"              = "https://${data.azurerm_storage_account.account.name}.blob.core.windows.net/${azurerm_storage_container.container.name}/${azurerm_storage_blob.function_blob.name}?${data.azurerm_storage_account_sas.account_sas.sas}"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.app_insights.connection_string
    "FUNCTIONS_WORKER_RUNTIME"              = "python"
    "FUNCTIONS_EXTENSION_VERSION"           = "~4"
    "AZURE_SUBSCRIPTION_ID"                 = var.azure_subscription_id
    "RESOURCE_GROUP_NAME"                   = var.resource_group_name
    "VMSS_NAME"                             = var.vmss_name
    "STORAGE_CONTAINER_NAME"                = azurerm_storage_container.container.name
    "STORAGE_ACCOUNT_NAME"                  = data.azurerm_storage_account.account.name
    "STORAGE_SAS_CONFIG"                    = data.azurerm_storage_account_sas.account_sas.sas
    "PRIVATE_INTERFACE_NAME"                = length(local.private_interface_names) == 1 ? local.private_interface_names[0] : ""
    "GWLB_FRONTEND_IP_ADDRESS"              = length(local.lb_frontend_ip_addresses) == 1 ? local.lb_frontend_ip_addresses[0] : ""
    "FORTIGATE_INSTANCE_USER_NAME"          = var.fortigate_username
    "FORTIGATE_INSTANCE_PASSWORD"           = var.fortigate_password
    "FORTIGATE_LICENSE_SOURCE"              = var.fortigate_license_source
    "AUTOSCALE_PSKSECRET"                   = var.fortigate_autoscale_psksecret
    "FORTIFLEX_USERNAME"                    = var.fortiflex_api_username
    "FORTIFLEX_PASSWORD"                    = var.fortiflex_api_password
    "FORTIFLEX_CONFIG_ID"                   = var.fortiflex_config_id
    "FORTIFLEX_RETRIEVE_MODE"               = var.fortiflex_retrieve_mode
    "USE_FMG_INTEGRATION"                   = var.fmg_integration != null
    "LICENSE_TYPE"                          = var.license_type
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [azurerm_storage_blob.function_blob]
}

data "azurerm_function_app_host_keys" "function_app_keys" {
  name                = azurerm_linux_function_app.function_app.name
  resource_group_name = var.resource_group_name

  depends_on = [azurerm_linux_function_app.function_app]
}

# Assign Reader role to Function App's Managed Identity
resource "azurerm_role_assignment" "role_assignment" {
  principal_id         = azurerm_linux_function_app.function_app.identity[0].principal_id
  role_definition_name = "Reader"
  scope                = azurerm_linux_virtual_machine_scale_set.vmss.id
}

# Define a storage container for function code
resource "azurerm_storage_container" "container" {
  name                  = "function-code"
  storage_account_id    = data.azurerm_storage_account.account.id
  container_access_type = "private"
}

# Upload the Function App package to the storage account
resource "azurerm_storage_blob" "function_blob" {
  name                   = "functionapp.zip"
  storage_account_name   = data.azurerm_storage_account.account.name
  storage_container_name = azurerm_storage_container.container.name
  type                   = "Block"
  source                 = "${path.module}/function_app.zip"

  lifecycle {
    create_before_destroy = true
  }
}

# Upload all file type licenses to the container
resource "azurerm_storage_blob" "fortigate_licenses" {
  for_each               = var.fortigate_license_folder_path != null ? fileset(var.fortigate_license_folder_path, "*.lic") : []
  name                   = "licenses/${each.value}"
  storage_account_name   = data.azurerm_storage_account.account.name
  storage_container_name = azurerm_storage_container.container.name
  type                   = "Block"
  source                 = "${var.fortigate_license_folder_path}/${each.value}"
}

data "http" "function_health_check" {
  url                = local.handle_scale_event_endpoint
  method             = "POST"
  request_body       = "{\"reason\": \"TFE health check\"}"
  request_timeout_ms = 3 * 60 * 1000
  retry {
    attempts = 6
  }

  lifecycle {
    postcondition {
      condition     = contains([200], self.status_code)
      error_message = "Internal error from calling handle_auto_scale_events"
    }
  }

  depends_on = [
    azurerm_linux_function_app.function_app,
    azurerm_linux_virtual_machine_scale_set.vmss,
  ]
}

# Validate fortigate sku/version configurations
data "local_file" "fortinet_sku_to_versions_map_file" {
  filename = "${path.module}/fortinet_sku_to_versions_map.json"
}

resource "null_resource" "validate_image_version" {
  provisioner "local-exec" {
    command = <<EOT
    if ! ${local.image_version_valid}; then
      echo "Error: Fortinet image version ${var.image_version} not found, please check with the command  az vm image list -o table --all --publisher fortinet --offer fortinet_fortigate-vm_v5 to list all the available products!"
      exit 1
    fi
    EOT
  }
}

data "azurerm_virtual_machine_scale_set" "vmss_instance" {
  resource_group_name = var.resource_group_name
  name                = azurerm_linux_virtual_machine_scale_set.vmss.name
}
