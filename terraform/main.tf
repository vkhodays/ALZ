locals {
  # tflint-ignore: terraform_unused_declarations
  subscription_ids = {
    identity     = data.terraform_remote_state.core.outputs.subscription_identity
    connectivity = data.terraform_remote_state.core.outputs.subscription_connectivity
    management   = data.terraform_remote_state.core.outputs.subscription_management
  }
}

module "retail-xcenter" {
  # tflint-ignore: terraform_module_pinned_source
  source = "git::https://dev.azure.com/RalphLauren/Azure%20Landing%20Zones/_git/Terraform.IaaSLandingZone?ref=feature/initial"

  providers = {
    azurerm = azurerm
    azuread = azuread
    azapi   = azapi
    time    = time
  }

  primary_location = "eastus"

  platform_environment = var.platform_environment
  app_environment      = var.app_environment
  billing_scope        = var.billing_scope

  virtual_networks = {
    southeastasia = {
      location = "southeastasia"
      address_space = {
        npd = ["10.212.2.0/28", "10.212.2.32/27"]
        prd = ["10.212.3.0/28", "10.212.3.32/27"]
      }
      dns_servers = ["10.212.0.100"]
    }
  }

  rbac = {
    template_name = "standard"
  }

  directory_roles = [
    "Directory Readers"
  ]
  
  management_group    = "retail-internal"
  subscription_name   = "retail-xcenter"
  subscription_tags = {
    WorkloadName        = "XCenter"
    DataClassification  = "General"
    BusinessCriticality = "Mission-critical"
    BusinessUnit        = "Retail"
    OperationsTeam      = "Retail"
  }
}
