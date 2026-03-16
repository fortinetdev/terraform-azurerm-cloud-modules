terraform {
  required_version = ">= 1.3, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.13"
    }
    http = {
      source = "hashicorp/http"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    # Used for VMSS rolling upgrade, default is true
    # virtual_machine_scale_set {
    #   roll_instances_when_required = false
    # }
  }

  subscription_id = var.azure_subscription_id
}
