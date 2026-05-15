Deploy a single Fortinet product on Azure, including FortiGate, FortiManager, FortiAnalyzer, FortiGuest, or FortiAIOps, using the streamlined and efficient Terraform module `generic_vm_standalone`.

**Introduction**

This Terraform module, located at `/modules/fortinet/generic_vm_standalone`, provides a streamlined solution for deploying a single Fortinet Virtual Machine on Microsoft Azure. It supports a range of Fortinet products, including FortiGate, FortiManager, FortiAnalyzer, FortiGuest, and FortiAIOps. By following the steps outlined below, you can efficiently set up and configure your desired Fortinet product in the Azure environment.

**Supported Product Names and Image Versions**
To deploy a Fortinet product, the `product_name` and `image_version` parameters are mandatory. Users must refer to the table below to select the appropriate product name and image version based on the product description and supported image versions.

| Product Name          | Supported Image Versions | Description                              | SKU for the product name                                                     |
|------------------------|--------------------|------------------------------------------|-----------------------------------------------------------------------------|
| fortimanager           | 6.2.0 - 8.0.0     | Centralized management for Fortinet devices | fortinet-fortimanager               |
| fortianalyzer          | 6.2.0 - 8.0.0     | Log management and analytics for Fortinet devices | fortinet-fortianalyzer        |
| fortiguest             | 2.0.00205 - 2.4.20520 | Guest management solution                | fortinet_fortiguest-vm         |
| fortiaiops             | 2.0.1 - 3.2.1 | AI-powered operations for Fortinet devices | fortinet_fortiaiops-vm               |
| fortigate              | 6.2.0 - 7.6.0     | BYOL Next-generation firewall                 | fortinet_fg-vm                |
| fortigate-arm64        | 7.2.10 - 7.6.2     | BYOL ARM64-based next-generation firewall     | fortinet_fg-vm_arm64              |
| fortigate-g2           | 7.6.1, 7.6.2    | BYOL Second-generation next-generation firewall | fortinet_fg-vm_g2                   |
| fortigate-payg         | 6.4.13 - 7.4.7    | Pay-as-you-go next-generation firewall   | fortinet_fg-vm_payg_2023             |
| fortigate-payg-g2      | 7.6.1, 7.6.2     | Pay-as-you-go second-generation firewall | fortinet_fg-vm_payg_2023_g2           |
| fortigate-payg-arm64   | 7.2.10 - 7.6.2     | Pay-as-you-go ARM64-based firewall       | fortinet_fg-vm_payg_2023_arm64       |


**Deployment Steps**

1. Select a product deployment example from the options below and carefully review all the parameters provided.
2. Replace all placeholder values marked as `"YOUR_OWN_VALUE"` with the appropriate values specific to your deployment requirements.
3. Execute the following commands to initialize and apply the Terraform configuration:

  ```sh
  terraform init
  terraform apply
  ```

**Example Usage of the `generic_vm_standalone` Module for Various Fortinet Products**

Below are examples of how to deploy a single FortiGuest, FortiAIOPS, FortiGate, FortiManager, FortiAnalyzer using the `generic_vm_standalone` Terraform module. Replace all placeholder values marked as `"YOUR_OWN_VALUE"` with your specific deployment details. Ensure you review and adjust the parameters to match your specific requirements.

> **Note**: For FortiGuest and FortiAIOPS deployments, when accessing the VM via SSH or GUI for the first time, use the default `admin` as the username and empty string as the password. You will then be prompted to set a new password of your choice. For any other products, please use your own values for both admin_user and admin_password.

#### FortiGuest Deployment Example

```hcl
module "single_vm" {
  source = "fortinetdev/cloud-modules/azurerm/modules/fortinet/generic_vm_standalone"

  azure_subscription_id = "YOUR_OWN_VALUE"

  # prefix used for all top level resources
  prefix = "single_fortiguest_test"

  # Only needed if you'd like to use the existing resources.
  # resource_group_name  = "YOUR_OWN_VALUE"
  # virtual_network_name = "YOUR_OWN_VALUE"
  # subnet_name          = "YOUR_OWN_VALUE"

  location = "Central US"

  # Only needed if you'd like to create new vnet and subnet (not using the existing resources.) Your own values for vnet_address_space and subnet_address_prefixes. Default values will be used if not provided.
  vnet_address_space      = ["10.0.0.0/16"]
  subnet_address_prefixes = ["10.0.1.0/24"]

  # Check the product name in /docs/generic_vm_standalone.md
  product_name  = "fortiguest"
  image_version = "2.0.00205"
  vm_size       = "Standard_D4_v3"

  # network_interfaces, set public_IP_creation_flag to true will creat a piblic IP. Define more interfaces as needed.
  network_interfaces = [
    {
      name                    = "port1"
      public_IP_creation_flag = true
    }
  ]

  nsg_rules = [
    {
      name                       = "Allow-SSH"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "Allow-HTTPS"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "Allow-UDP-1812"
      priority                   = 300
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_range     = "1812"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "Allow-UDP-1813"
      priority                   = 400
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_range     = "1813"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}
```

#### FortiAIOPS Deployment Example

```hcl
module "single_vm" {
  source = "fortinetdev/cloud-modules/azurerm/modules/fortinet/generic_vm_standalone"

  azure_subscription_id = "YOUR_OWN_VALUE"

  # Prefix for all top-level resources
  prefix = "single_fortiaiops_test"

  # Location for deployment
  location = "Central US"

  # Only needed if you'd like to use the existing resources.
  # resource_group_name  = "YOUR_OWN_VALUE"
  # virtual_network_name = "YOUR_OWN_VALUE"
  # subnet_name          = "YOUR_OWN_VALUE"

  # Virtual network and subnet configuration
  vnet_address_space      = ["10.0.0.0/16"]
  subnet_address_prefixes = ["10.0.1.0/24"]

  # Check the product name in /docs/generic_vm_standalone.md
  product_name  = "fortiaiops"
  image_version = "2.1.0"
  vm_size       = "Standard_E4_v4"

  # Network interfaces
  network_interfaces = [
    {
      name                    = "port1"
      public_IP_creation_flag = true
    }
  ]

  nsg_rules = [
    {
      name                       = "Allow-SSH"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "Allow-HTTPS"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "Allow-UDP-514"
      priority                   = 300
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_range     = "514"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "Allow-UDP-4013"
      priority                   = 400
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_range     = "4013"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}
```
#### FortiGate/fortiManager/FortiAnalyzer Deployment Example

```hcl
module "single_vm" {
  source = "fortinetdev/cloud-modules/azurerm/modules/fortinet/generic_vm_standalone"

  azure_subscription_id = "YOUR_OWN_VALUE"

  # prefix used for all top level resources
  prefix = "single_fortigate_test"

  # Only needed if you'd like to use the existing resources.
  # resource_group_name  = "YOUR_OWN_VALUE"
  # virtual_network_name = "YOUR_OWN_VALUE"
  # subnet_name          = "YOUR_OWN_VALUE"

  location = "Central US"

  # Only needed if you'd like to create new vnet and subnet (not using the existing resources.) Your own values for vnet_address_space and subnet_address_prefixes. Default values will be used if not provided.
  vnet_address_space      = ["10.0.0.0/16"]
  subnet_address_prefixes = ["10.0.1.0/24"]

  # username for accessing the vm
  admin_username = "azureadmin"
  admin_password = "Fortinet@123456!"

  # network_interfaces, set public_IP_creation_flag to true will creat a piblic IP. Define more interfaces as needed.
  network_interfaces = [
    {
      name                    = "port1"
      public_IP_creation_flag = true
    },
    {
      name = "port2"
    }
  ]

  nsg_rules = [
    {
      name                       = "Allow-SSH"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "Allow-HTTPS"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]

  # Check the product name in /docs/generic_vm_standalone.md
  product_name  = "fortigate" # fortimanager, fortianalyzer
  image_version = "7.6.0"
  vm_size       = "Standard_D2s_v3" # vm size may vary for different products.

  # Provide either file license or flextoken.
  # license_file_path      = "YOUR_OWN_VALUE" # e.g. "./license.lic"
  # license_fortiflex      = "YOUR_OWN_VALUE"

  # Provide the file path if you have any additional custom config.
  # custom_data_file_path = "YOUR_OWN_VALUE" # e.g. "./custom_data.conf"
}
```

#### Output Info

```hcl
# The output info for the deployed instance. Modify the output as needed.
output "instance_info" {
  description = "The public IP address of the instance VM"
  value       = module.single_vm
}
```

**Post-Deployment: Instance Information**

Once the deployment is complete, Terraform will display the following information:

Public IP Address: The public IP assigned to the instance.
Network Interfaces: The associated network interfaces for the VM.
This output can be helpful for connecting to the VM and verifying the deployment.

Feel free to output more info as needed.

The FortiAIOps instance may take longer to initialize compared to other products. Please allow some time after deployment before accessing the VM via SSH or GUI.
