locals {
  resource_group_name    = var.resource_group_creation_flag ? azurerm_resource_group.rg[0].name : data.azurerm_resource_group.existing_group[0].name
  virtual_network_name   = var.virtual_network_creation_flag ? azurerm_virtual_network.vnet[0].name : data.azurerm_virtual_network.existing_vnet[0].name
  subnet                 = var.subnet_creation_flag ? azurerm_subnet.subnet[0] : data.azurerm_subnet.existing_subnet[0]
  image_version_is_train = can(regex("^\\d+\\.\\d+$", var.image_version))
  image_version_train    = can(regex("^\\d+\\.\\d+", var.image_version)) ? replace(regex("^\\d+\\.\\d+", var.image_version), ".", "") : var.image_version
  fortigate_gen_suffix   = var.gen_type == "g2" ? "_g2" : ""
  fortigate_arch_suffix  = var.architecture == "arm64" ? "_arm64" : ""
  fortigate_dynamic_sku  = "fortinet_fg-vm_${var.license_type}_${local.image_version_train}${local.fortigate_gen_suffix}${local.fortigate_arch_suffix}"

  effective_image_offer   = var.image_offer != "" ? var.image_offer : (startswith(var.product_name, "fortigate") ? local.image_offer_tempate["fortigate"] : local.image_offer_tempate[var.product_name])
  effective_image_sku     = var.image_sku != "" ? var.image_sku : (startswith(var.product_name, "fortigate") ? local.fortigate_dynamic_sku : local.image_sku_template[var.product_name])
  effective_image_version = (startswith(var.product_name, "fortigate") && local.image_version_is_train) ? "latest" : var.image_version

  image_sku_template = {
    "fortiaiops"    = "fortinet_fortiaiops-vm"
    "fortianalyzer" = "fortinet-fortianalyzer"
    "fortiguest"    = "fortinet_fortiguest-vm"
    "fortimanager"  = "fortinet-fortimanager"
    "fortigate"     = local.fortigate_dynamic_sku
  }

  image_offer_tempate = {
    "fortiaiops"    = "fortinet-fortiaiops"
    "fortianalyzer" = "fortinet-fortianalyzer"
    "fortiguest"    = "fortinet-fortiguest"
    "fortimanager"  = "fortinet-fortimanager"
    "fortigate"     = "fortinet_fortigate-vm"
  }
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  count    = var.resource_group_creation_flag ? 1 : 0
  name     = "${var.prefix}-rg"
  location = var.location
  tags     = var.tags
}

data "azurerm_resource_group" "existing_group" {
  count = var.resource_group_creation_flag ? 0 : 1
  name  = try(var.resource_group_name, null)
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  count               = var.virtual_network_creation_flag ? 1 : 0
  name                = "${var.prefix}-vnet"
  location            = var.location
  resource_group_name = local.resource_group_name
  address_space       = try(var.vnet_address_space, ["10.0.0.0/16"])
  tags                = var.tags
}

data "azurerm_virtual_network" "existing_vnet" {
  count               = var.virtual_network_creation_flag ? 0 : 1
  resource_group_name = local.resource_group_name
  name                = try(var.virtual_network_name, null)
}

# Subnet for the insctance
resource "azurerm_subnet" "subnet" {
  count                = var.subnet_creation_flag ? 1 : 0
  name                 = "${var.prefix}-subnet"
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network_name
  address_prefixes     = try(var.subnet_address_prefixes, ["10.0.1.0/24"])
}

data "azurerm_subnet" "existing_subnet" {
  count                = var.subnet_creation_flag ? 0 : 1
  name                 = try(var.subnet_name, null)
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network_name
}

# Public IP for the instance
# This will create a public IP for each network interface that has the public_IP_creation_flag set to true
# If the public_IP_creation_flag is false, the public IP will not be created
resource "azurerm_public_ip" "pip" {
  for_each            = { for nic in var.network_interfaces : nic.name => nic if nic.public_IP_creation_flag == true }
  name                = "public-ip-${each.key}"
  resource_group_name = local.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network Interface for the instance
resource "azurerm_network_interface" "nic" {
  for_each = { for nic in var.network_interfaces : nic.name => nic }

  name                = each.value.name
  location            = var.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "${each.value.name}-ip-config"
    subnet_id                     = var.subnet_creation_flag ? azurerm_subnet.subnet[0].id : data.azurerm_subnet.existing_subnet[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = each.value.public_IP_creation_flag ? azurerm_public_ip.pip[each.key].id : null
  }

  depends_on = [
    azurerm_public_ip.pip,
    azurerm_subnet.subnet
  ]
}

# Network Security Group to allow necessary ports
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  location            = var.location
  resource_group_name = local.resource_group_name

  dynamic "security_rule" {
    for_each = var.nsg_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_asso" {
  subnet_id                 = local.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id

  depends_on = [
    azurerm_subnet.subnet,
    azurerm_network_security_group.nsg
  ]
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  for_each = azurerm_network_interface.nic

  network_interface_id      = each.value.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Forti-VM instance
resource "azurerm_linux_virtual_machine" "instance_vm" {
  name                = "${var.product_name}-vm"
  resource_group_name = local.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = flatten([
    for nic in azurerm_network_interface.nic : nic.id
  ])

  source_image_reference {
    publisher = var.image_publisher
    offer     = local.effective_image_offer
    sku       = local.effective_image_sku
    version   = local.effective_image_version
  }

  plan {
    name      = local.effective_image_sku
    publisher = var.image_publisher
    product   = local.effective_image_offer
  }

  custom_data = base64encode(templatefile("${path.module}/${var.bootstrap_template}", {
    license_fortiflex     = var.license_fortiflex,
    license_file_path     = var.license_file_path,
    custom_data_file_path = var.custom_data_file_path
  }))

  os_disk {
    caching                = "ReadWrite"
    storage_account_type   = var.storage_account_type
    disk_encryption_set_id = var.disk_encryption_set_id
  }

  disable_password_authentication = false

  depends_on = [
    azurerm_network_interface.nic,
    azurerm_public_ip.pip,
    azurerm_subnet.subnet,
    azurerm_network_security_group.nsg
  ]


  tags = var.tags
}
