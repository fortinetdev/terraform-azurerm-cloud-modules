locals {
  resource_group_name = var.resource_group_creation_flag ? azurerm_resource_group.new_group[0].name : data.azurerm_resource_group.existing_group[0].name
}

resource "azurerm_resource_group" "new_group" {
  count    = var.resource_group_creation_flag ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

data "azurerm_resource_group" "existing_group" {
  count = var.resource_group_creation_flag ? 0 : 1
  name  = var.resource_group_name
}

# VNet
module "vnet" {
  for_each                = var.vnets
  source                  = "../../modules/azure/vnet"
  resource_group_name     = local.resource_group_name
  location                = var.location
  vnet_name               = each.value.vnet_name
  create_virtual_network  = try(each.value.create_virtual_network, true)
  address_space           = try(each.value.create_virtual_network, true) ? each.value.address_space : []
  create_subnets          = try(each.value.create_subnets, true)
  subnets                 = each.value.subnets
  network_security_groups = try(each.value.network_security_groups, {})
  tags                    = var.tags
}

# Gateway Load Balancer
module "gwlb" {
  for_each            = var.gateway_load_balancers
  source              = "../../modules/azure/gwlb"
  gwlb_name           = each.value.gwlb_name
  resource_group_name = try(each.value.resource_group_name, local.resource_group_name)
  location            = var.location
  backend_pools       = each.value.backend_pools
  health_probe        = each.value.health_probe
  frontend_ip_config = {
    name                          = try(each.value.frontend_ip_config.name, "${each.value.gwlb_name}-frontend")
    private_ip_address_allocation = try(each.value.frontend_ip_config.private_ip_address_allocation, null)
    private_ip_address_version    = try(each.value.frontend_ip_config.private_ip_address_version, null)
    private_ip_address            = try(each.value.frontend_ip_config.private_ip_address, null)
    subnet_id                     = module.vnet[each.value.vnet_key].subnet_ids[each.value.subnet_key]
    zones                         = try(each.value.frontend_ip_config.zones, null)
  }
  tags = var.tags
}

resource "random_password" "psksecret" {
  length      = 20
  min_upper   = 1
  min_lower   = 10
  min_numeric = 1
  min_special = 1
}

resource "random_password" "random_fgt_password" {
  length      = 10
  min_upper   = 1
  min_lower   = 5
  min_numeric = 1
  min_special = 1
}

# FortiGate Auto Scale Group
module "fortigate_scaleset" {
  for_each                      = var.fortigate_scaleset
  source                        = "../../modules/fortigate/scaleset"
  location                      = try(var.location, "centralus")
  zones                         = each.value.zones
  azure_subscription_id         = var.azure_subscription_id
  resource_group_name           = local.resource_group_name
  storage_account_name          = try(each.value.storage_account_name, null)
  storage_account_creation_flag = try(each.value.storage_account_creation_flag, true)
  vmss_name                     = try(each.value.vmss_name, "fortigate-scaleset")
  image_version                 = try(each.value.image_version, "7.2.8")
  # image_sku                     = format("fortinet_fg-vm%s%s", each.value.license_type == "payg" ? "_payg_2023" : "", try(each.value.architecture, "") == "Arm64" ? "_arm64" : "")

  image_sku = format(
    "fortinet_fg-vm%s%s%s",
    each.value.license_type == "payg" ? "_payg_2023" : "",
    try(each.value.architecture, "") == "Arm64" ? "_arm64" : "",
    contains(["7.6.1", "7.6.2", "7.6.3", "7.6.4"], each.value.image_version) ? "_g2" : ""
  )

  license_type = try(each.value.license_type, "byol")

  application_insights_id = try(each.value.application_insights_id, null)
  network_interfaces = [for interface in each.value.network_interfaces :
    {
      name                   = interface.name
      subnet_id              = module.vnet[each.value.vnet_key].subnet_ids[interface.subnet_key]
      create_pip             = try(interface.create_public_ip, false)
      gateway_ip_address     = interface.gateway_ip_address
      lb_backend_pool_ids    = try(interface.gwlb_key, null) != null && try(interface.gwlb_backend_key, null) != null ? [module.gwlb[interface.gwlb_key].backend_pool_ids[interface.gwlb_backend_key]] : []
      lb_frontend_ip_address = try(interface.gwlb_key, null) != null ? module.gwlb[interface.gwlb_key].private_ip_address : ""
    }
  ]

  fortigate_username            = try(each.value.fortigate_username, "fgtadmin")
  fortigate_password            = try(each.value.fortigate_password, random_password.random_fgt_password)
  fortigate_license_folder_path = try("${path.cwd}/${each.value.fortigate_license_folder_path}", "./licenses")
  fortigate_autoscale_psksecret = random_password.psksecret.result
  fortigate_custom_config       = file(try(each.value.fortigate_custom_config_file_path, "fortigate_custom_config.conf"))
  fortiflex_api_username        = try(each.value.fortiflex_api_username, null)
  fortiflex_api_password        = try(each.value.fortiflex_api_password, null)
  fortiflex_config_id           = try(each.value.fortiflex_config_id, null)
  fortiflex_retrieve_mode       = try(each.value.fortiflex_retrieve_mode, "use_active")
  enable_accelerated_networking = try(each.value.enable_accelerated_networking, true)
  data_type                     = try(each.value.data_type, "custom_data")
  autoscale_notification_emails = try(each.value.autoscale_notification_emails, [])
  min_count                     = try(each.value.min_count, 1)
  max_count                     = try(each.value.max_count, 1)
  default_count                 = try(each.value.default_count, 1)
  autoscale_metrics             = try(each.value.autoscale_metrics, {})
  vm_size                       = try(each.value.vm_size, "Standard_D2s_v3")
  fmg_integration               = try(each.value.fmg_integration, null)

  tags = var.tags
  depends_on = [
    module.vnet,
    module.gwlb,
    random_password.psksecret,
  ]
}

# Standard Load Balancer connects with your applications
module "standard_load_balancer" {
  for_each                    = var.standard_load_balancers
  source                      = "../../modules/azure/standard_load_balancer"
  lb_name                     = each.value.lb_name
  location                    = var.location
  resource_group_name         = local.resource_group_name
  avzones                     = try(each.value.avzones, null)
  network_security_group_name = try(each.value.network_security_group_name, null)
  frontend_ips = {
    for k, v in each.value.frontend_ips : k => {
      create_public_ip                                   = try(v.create_public_ip, false)
      public_ip_name                                     = try(v.public_ip_name, null)
      public_ip_resource_group                           = try(v.public_ip_resource_group, null)
      private_ip_address                                 = try(v.private_ip_address, null)
      subnet_id                                          = try(module.vnet[v.vnet_key].subnet_ids[v.subnet_key], null)
      inbound_rules                                      = try(v.inbound_rules, {})
      outbound_rules                                     = try(v.outbound_rules, {})
      zones                                              = try(v.zones, null)
      gateway_load_balancer_frontend_ip_configuration_id = try(v.gwlb_key, null) != null ? module.gwlb[v.gwlb_key].frontend_ip_config_id : null
    }
  }
  tags       = var.tags
  depends_on = [module.vnet]
}
