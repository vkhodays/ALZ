locals {
  subscription_ids = {
    identity     = data.terraform_remote_state.core.outputs.subscription_identity
    connectivity = data.terraform_remote_state.core.outputs.subscription_connectivity
    management   = data.terraform_remote_state.core.outputs.subscription_management
  }
}

moved {
  from = module.global-logitics-analytics
  to   = module.global-logitics-analytics[0]
}
module "global-logitics-analytics" {
  count = var.app_environment == "npd" ? 1 : 0 # only deploy to npd while in singapore.  remove this when changing to eastus
  # tflint-ignore: terraform_module_pinned_source
  source = "git::https://dev.azure.com/RalphLauren/Azure%20Landing%20Zones/_git/Terraform.DataLandingZone?ref=main"

  providers = {
    azurerm = azurerm
    azuread = azuread
    azapi   = azapi
    time    = time
  }

  platform_environment  = var.platform_environment
  app_environment       = var.app_environment
  primary_location      = "eastus"
  statefile_pe_location = "southeastasia" # remove this when the eastus region is available
  billing_scope         = var.billing_scope
  subscription_ids      = local.subscription_ids

  virtual_networks = {
    globlogsea = {
      location = "southeastasia" # To be changed to eastus when the region is available
      address_space = {
        npd = ["10.212.2.16/28", "10.212.8.0/22"]
        prd = ["10.212.2.32/28", "10.212.12.0/22"]
      }
      dns_servers = ["10.212.0.100"]
    }
  }

  rbac = {
    template_name          = "standard"
    create_groups          = var.app_environment == "npd"
    pim_enabled_if_defined = var.pim_enabled
  }

  directory_roles = [
    "Directory Readers"
  ]

  devops_project_name = "Logistics Analytics Data Platform"
  management_group    = "corp-internal"
  subscription_name   = "logistics-analytics"
  subscription_tags = {
    WorkloadName        = "Global Logistics Analytics"
    DataClassification  = "Confidential"
    BusinessCriticality = "Mission-critical"
    BusinessUnit        = "Global Logistics"
    OperationsTeam      = "Global Logistics"
  }


  analytics_environments = {
    npd = {
      dev = {
        location = "southeastasia" # To be changed to eastus when the region is available

        runtime_configuration = {
          enabled     = true
          subnet_cidr = "10.212.8.0/26"
        }

        vnet_key                                        = "globlogsea"
        storage_subnet_cidr                             = "10.212.8.64/27"
        external_subnet_cidr                            = "10.212.8.96/27"
        metadata_ingestion_subnet_cidr                  = "10.212.8.128/27"
        shared_analytics_subnet_cidr                    = "10.212.8.160/27"
        shared_analytics_databricks_private_subnet_cidr = "10.212.9.0/25"
        shared_analytics_databricks_public_subnet_cidr  = "10.212.9.128/25"
        db_administrator_entra_group_name               = "alz-global-platform_engineers"
        tags = {
          Environment = "Development"
        }
      }
      qa = {
        location = "southeastasia" # To be changed to eastus when the region is available

        runtime_configuration = {
          enabled     = true
          subnet_cidr = "10.212.10.0/26"
        }

        vnet_key                                        = "globlogsea"
        storage_subnet_cidr                             = "10.212.10.64/27"
        external_subnet_cidr                            = "10.212.10.96/27"
        metadata_ingestion_subnet_cidr                  = "10.212.10.128/27"
        shared_analytics_subnet_cidr                    = "10.212.10.160/27"
        shared_analytics_databricks_private_subnet_cidr = "10.212.11.0/25"
        shared_analytics_databricks_public_subnet_cidr  = "10.212.11.128/25"
        db_administrator_entra_group_name               = "alz-global-platform_engineers"
        tags = {
          Environment = "QA"
        }
      }
    }
    prd = {
      prd = {
        location = "southeastasia" # To be changed to eastus when the region is available

        runtime_configuration = {
          enabled     = true
          subnet_cidr = "10.212.12.0/26"
        }

        vnet_key                                        = "globlogsea"
        storage_subnet_cidr                             = "10.212.12.64/27"
        external_subnet_cidr                            = "10.212.12.96/27"
        metadata_ingestion_subnet_cidr                  = "10.212.12.128/27"
        shared_analytics_subnet_cidr                    = "10.212.12.160/27"
        shared_analytics_databricks_private_subnet_cidr = "10.212.13.0/24"
        shared_analytics_databricks_public_subnet_cidr  = "10.212.14.0/24"
        db_administrator_entra_group_name               = "alz-global-platform_engineers"
        tags = {
          Environment = "Production"
        }
      }
    }
  }
}

moved {
  from = module.retail-storesystems
  to   = module.global-retail-storesystems.module.landingzone
}
module "global-retail-storesystems" {
  # tflint-ignore: terraform_module_pinned_source
  source = "git::https://dev.azure.com/RalphLauren/Azure%20Landing%20Zones/_git/Terraform.IaaSLandingZone?ref=feature/rbac-uplift"

  providers = {
    azurerm = azurerm
    azuread = azuread
    azapi   = azapi
    time    = time
  }

  primary_location      = "eastus"
  statefile_pe_location = "southeastasia" # remove this when the eastus region is available

  platform_environment = var.platform_environment
  app_environment      = var.app_environment
  billing_scope        = var.billing_scope
  subscription_ids     = local.subscription_ids

  virtual_networks = {
    storesystemssea = {
      location = "southeastasia"
      address_space = {
        npd = ["10.212.2.48/28", "10.212.2.64/27", "10.212.2.96/27", "10.212.2.128/25"]
        prd = ["10.212.3.0/28", "10.212.3.32/27"]
      }

      dns_servers = ["10.212.0.100"]
    }
  }

  rbac = {
    template_name          = "standard"
    create_groups          = var.app_environment == "npd"
    pim_enabled_if_defined = var.pim_enabled
  }

  directory_roles = [
    "Directory Readers"
  ]

  devops_project_name = "Retail - Store Systems"
  management_group    = "retail-internal"
  subscription_name   = "retail-storesystems"
  subscription_tags = {
    WorkloadName        = "Store Systems"
    DataClassification  = "General"
    BusinessCriticality = "Mission-critical"
    BusinessUnit        = "Retail"
    OperationsTeam      = "Retail"
  }
}
