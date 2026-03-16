output "scale_set_name" {
  description = "The name of the created virtual machine scale set."
  sensitive   = true
  value = {
    name               = azurerm_linux_virtual_machine_scale_set.vmss.name
    type               = var.license_type
    fortigate_username = var.fortigate_username
    fortigate_password = var.fortigate_password
    public_ips         = data.azurerm_virtual_machine_scale_set.vmss_instance.instances.*.public_ip_address
  }
}
