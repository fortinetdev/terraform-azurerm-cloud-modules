locals {
  frontend_addresses = {
    for v in azurerm_lb.lb.frontend_ip_configuration : v.name => try(data.azurerm_public_ip.data_pip[v.name].ip_address, try(azurerm_public_ip.pip[v.name].ip_address, azurerm_lb.lb.frontend_ip_configuration[0].private_ip_address))
  }

  # Flatten and organize inbound and outbound rules
  flat_inbound_rules = flatten([
    for frontend_key, frontend_config in var.frontend_ips : [
      for rule_key, rule in try(frontend_config.inbound_rules, {}) : {
        frontend_key    = frontend_key
        frontend_config = frontend_config
        rule_key        = rule_key
        rule            = rule
      }
    ]
  ])
  inbound_rules = { for v in local.flat_inbound_rules : "${v.frontend_key}-${v.rule_key}" => v }

  flat_outbound_rules = flatten([
    for frontend_key, frontend_config in var.frontend_ips : [
      for rule_key, rule in try(frontend_config.outbound_rules, {}) : {
        frontend_key    = frontend_key
        frontend_config = frontend_config
        rule_key        = rule_key
        rule            = rule
      }
    ]
  ])
  outbound_rules = { for v in local.flat_outbound_rules : "${v.frontend_key}-${v.rule_key}" => v }

  # Check if any frontend IP configurations have outbound rules
  disable_outbound_snat = anytrue([for _, v in var.frontend_ips : try(length(v.outbound_rules) > 0, false)])
}

resource "azurerm_public_ip" "pip" {
  for_each            = { for k, v in var.frontend_ips : k => v if try(v.create_public_ip, false) }
  name                = "${var.lb_name}-${each.key}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = try(var.avzones, null)
  tags                = var.tags
}

data "azurerm_public_ip" "data_pip" {
  for_each = {
    for k, v in var.frontend_ips : k => v
    if try(v.public_ip_name, null) != null && !try(v.create_public_ip, false)
  }
  name                = try(each.value.public_ip_name, "")
  resource_group_name = try(each.value.public_ip_resource_group, var.resource_group_name, "")
}

resource "azurerm_lb" "lb" {
  name                = var.lb_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  tags                = var.tags

  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_ips
    iterator = each
    content {
      name                                               = each.key
      public_ip_address_id                               = try(each.value.create_public_ip, false) ? azurerm_public_ip.pip[each.key].id : try(data.azurerm_public_ip.data_pip[each.key].id, null)
      subnet_id                                          = try(each.value.subnet_id, null)
      private_ip_address_allocation                      = try(each.value.private_ip_address, null) != null ? "Static" : null
      private_ip_address                                 = try(each.value.private_ip_address, null)
      zones                                              = try(each.value.subnet_id, null) != null ? var.avzones : []
      gateway_load_balancer_frontend_ip_configuration_id = try(each.value.gateway_load_balancer_frontend_ip_configuration_id, null)
    }
  }
}

resource "azurerm_lb_backend_address_pool" "lb_backend" {
  name            = var.backend_pool_name
  loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "probe" {
  name            = var.probe_name
  loadbalancer_id = azurerm_lb.lb.id
  port            = var.probe_port
}

resource "azurerm_lb_rule" "in_rules" {
  for_each                       = local.inbound_rules
  name                           = each.key
  loadbalancer_id                = azurerm_lb.lb.id
  probe_id                       = azurerm_lb_probe.probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb_backend.id]
  protocol                       = each.value.rule.protocol
  backend_port                   = coalesce(try(each.value.rule.backend_port, null), each.value.rule.port)
  frontend_ip_configuration_name = each.value.frontend_key
  frontend_port                  = each.value.rule.port
  floating_ip_enabled            = try(each.value.rule.floating_ip_enabled, true)
  disable_outbound_snat          = local.disable_outbound_snat
  load_distribution              = try(each.value.rule.load_distribution, "SourceIPProtocol")
}

resource "azurerm_lb_outbound_rule" "out_rules" {
  for_each                 = local.outbound_rules
  name                     = each.key
  loadbalancer_id          = azurerm_lb.lb.id
  backend_address_pool_id  = azurerm_lb_backend_address_pool.lb_backend.id
  protocol                 = each.value.rule.protocol
  tcp_reset_enabled        = each.value.rule.protocol != "Udp" ? try(each.value.rule.tcp_reset_enabled, null) : null
  allocated_outbound_ports = try(each.value.rule.allocated_outbound_ports, null)
  idle_timeout_in_minutes  = each.value.rule.protocol != "Udp" ? try(each.value.rule.idle_timeout_in_minutes, null) : null

  frontend_ip_configuration {
    name = each.value.frontend_key
  }
}
