locals {
  #eastasia_virtual_hub_id = data.terraform_remote_state.core.outputs.azurerm_virtual_hub_ids["eastasia"]
  southeastasia_virtual_hub_id = data.terraform_remote_state.core.outputs.azurerm_virtual_hub_ids["southeastasia"]
  subscription_ids = {
    identity     = data.terraform_remote_state.core.outputs.subscription_identity
    connectivity = data.terraform_remote_state.core.outputs.subscription_connectivity
    management   = data.terraform_remote_state.core.outputs.subscription_management
  }
}

module "orca" {
  # tflint-ignore: terraform_module_pinned_source
  source = "git::https://dev.azure.com/RalphLauren/Azure%20Landing%20Zones/_git/Terraform.LandingZones?ref=20240718.1"

  providers = {
    azurerm = azurerm
    azuread = azuread
    azapi   = azapi
    time    = time
  }

  platform_environment = var.platform_environment
  app_environment      = var.app_environment
  billing_scope        = var.billing_scope
  subscription_ids     = local.subscription_ids

  virtual_networks = {
    main = {
      azurerm_virtual_hub_id = local.southeastasia_virtual_hub_id
      address_space = {
        dev = ["172.28.200.0/26"]
        pre = ["172.28.200.64/26"]
        prd = ["172.28.200.192/26"]
      }
      dns_servers = ["172.28.0.132", "172.28.128.132"]
    }
  }

  rbac = {
    template_name = "standard"
    create_groups = var.app_environment == "dev"
  }

  directory_roles = [
    "Directory Readers"
  ]

  devops_project_name = "Azure Landing Zones"
  management_group    = "internal"
  subscription_name   = "orca"
  subscription_tags = {
    WorkloadName        = "ALZ.Core"
    DataClassification  = "General"
    BusinessCriticality = "Mission-critical"
    BusinessUnit        = "Platform Operations"
    OperationsTeam      = "Platform Operations"
  }
}
