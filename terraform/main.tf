locals {
  subscription_ids = {
    identity     = data.terraform_remote_state.core.outputs.subscription_identity
    connectivity = data.terraform_remote_state.core.outputs.subscription_connectivity
    management   = data.terraform_remote_state.core.outputs.subscription_management
  }
}

moved {
  from = module.global-logitics-analytics[0]
  to   = module.global-logitics-analytics
}
module "global-logitics-analytics" {
  source = "git::https://dev.azure.com/RalphLauren/Azure%20Landing%20Zones/_git/Terraform.DataLandingZone?ref=20241014.6"

  providers = {
    azurerm = azurerm
    azuread = azuread
    azapi   = azapi
    time    = time
  }

  platform_environment  = var.platform_environment
  app_environment       = var.app_environment
  primary_location      = "eastus"
  billing_scope         = var.billing_scope
  subscription_ids      = local.subscription_ids

  virtual_networks = {
    globlogeus = {
      location = "eastus"
      address_space = {
        npd = ["10.232.240.0/21", "10.232.100.0/23"]
        prd = ["10.232.88.0/24", "10.232.220.0/22"]
      }
      dns_servers = ["10.232.0.196"]
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
  short_name          = "ladp"
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
        location = "eastus"

        runtime_configuration = {
          enabled     = true
          subnet_cidr = "10.232.241.0/26"
        }

        vnet_key                                        = "globlogeus"
        storage_subnet_cidr                             = "10.232.240.128/27"
        external_subnet_cidr                            = "10.232.240.160/27"
        metadata_ingestion_subnet_cidr                  = "10.232.240.192/27"
        shared_analytics_subnet_cidr                    = "10.232.240.224/27"
        shared_analytics_databricks_private_subnet_cidr = "10.232.242.0/23"
        shared_analytics_databricks_public_subnet_cidr  = "10.232.244.0/23"
        db_administrator_entra_group_name               = "alz-global-platform_engineers"
        tags = {
          Environment = "Development"
        }
      }
      qa = {
        location = "eastus"

        runtime_configuration = {
          enabled     = true
          subnet_cidr = "10.232.241.64/26"
        }

        vnet_key                                        = "globlogeus"
        storage_subnet_cidr                             = "10.232.241.128/27"
        external_subnet_cidr                            = "10.232.241.160/27"
        metadata_ingestion_subnet_cidr                  = "10.232.241.192/27"
        shared_analytics_subnet_cidr                    = "10.232.241.224/27"
        shared_analytics_databricks_private_subnet_cidr = "10.232.246.0/23"
        shared_analytics_databricks_public_subnet_cidr  = "10.232.100.0/23"
        db_administrator_entra_group_name               = "alz-global-platform_engineers"
        tags = {
          Environment = "QA"
        }
      }
    }
    prd = {
      prd = {
        location = "eastus"

        runtime_configuration = {
          enabled     = true
          subnet_cidr = "10.232.88.64/26"
        }

        vnet_key                                        = "globlogeus"
        storage_subnet_cidr                             = "10.232.88.128/27"
        external_subnet_cidr                            = "10.232.88.160/27"
        metadata_ingestion_subnet_cidr                  = "10.232.88.192/27"
        shared_analytics_subnet_cidr                    = "10.232.88.224/27"
        shared_analytics_databricks_private_subnet_cidr = "10.232.220.0/23"
        shared_analytics_databricks_public_subnet_cidr  = "10.232.222.0/23"
        db_administrator_entra_group_name               = "alz-global-platform_engineers"
        tags = {
          Environment = "Production"
        }
      }
    }
  }
}

module "retail-storesystems" {
  # tflint-ignore: terraform_module_pinned_source
  source = "git::https://dev.azure.com/RalphLauren/Azure%20Landing%20Zones/_git/Terraform.LandingZones?ref=20241014.8"

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
    retail_southeastasia = {
      location = "southeastasia"
      address_space = {
        npd = ["10.212.16.0/21"]
        prd = ["10.212.24.0/21"]
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

  recovery_services_vault_enabled = true
  recovery_services_vault_use_private_endpoint = true
  recovery_services_vault_enable_public_network_access = false
}

moved {
  from = module.retail-storesystems.module.subscription.module.virtualnetwork[0].azapi_resource.rg["vnet-storesystemssea"]
  to   = module.retail-storesystems.module.subscription.module.virtualnetwork_0.azapi_resource.rg_vnet-storesystemssea
}

removed {
  from = module.retail-storesystems.module.subscription.module.virtualnetwork_0.azapi_resource.rg_vnet-storesystemssea

  lifecycle {
    destroy = false
  }
}

moved {
  from = module.retail-storesystems.module.subscription.module.virtualnetwork[0].azapi_resource.rg_lock["vnet-storesystemssea"]
  to   = module.retail-storesystems.module.subscription.module.virtualnetwork_0.azapi_resource.rg_lock_vnet-storesystemssea
}

removed {
  from = module.retail-storesystems.module.subscription.module.virtualnetwork_0.azapi_resource.rg_lock_vnet-storesystemssea

  lifecycle {
    destroy = false
  }
}

moved {
  from = module.retail-storesystems.module.subscription.module.virtualnetwork[0].azapi_update_resource.vnet["storesystemssea"]
  to   = module.retail-storesystems.module.subscription.module.virtualnetwork_0.azapi_update_resource.vnet_storesystemssea
}

removed {
  from = module.retail-storesystems.module.subscription.module.virtualnetwork_0.azapi_update_resource.vnet_storesystemssea

  lifecycle {
    destroy = false
  }
}

moved {
  from = module.retail-storesystems.module.subscription.module.virtualnetwork[0].azapi_update_resource.vnet["storesystemssea"]
  to   = module.retail-storesystems.module.subscription.module.virtualnetwork_0.azapi_update_resource.vnet_storesystemssea
}

removed {
  from = module.retail-storesystems.module.subscription.module.virtualnetwork_0.azapi_update_resource.vnet_storesystemssea

  lifecycle {
    destroy = false
  }
}

moved {
  from = module.retail-storesystems.module.private_endpoint_subnets["storesystemssea"].azapi_resource.nsg
  to   = module.retail-storesystems.module.private_endpoint_subnets_storesystemssea.azapi_resource.nsg
}

removed {
  from = module.retail-storesystems.module.private_endpoint_subnets_storesystemssea.azapi_resource.nsg

  lifecycle {
    destroy = false
  }
}

moved {
  from = module.retail-storesystems.module.private_endpoint_subnets["storesystemssea"].azapi_resource.subnet
  to   = module.retail-storesystems.module.private_endpoint_subnets_storesystemssea.azapi_resource.subnet
}

removed {
  from = module.retail-storesystems.module.private_endpoint_subnets_storesystemssea.azapi_resource.subnet

  lifecycle {
    destroy = false
  }
}

moved {
  from = module.retail-storesystems.module.subscription.module.virtualnetwork[0].azapi_resource.vnet["storesystemssea"]
  to   = module.retail-storesystems.module.subscription.module.virtualnetwork_0.azapi_resource.vnet_storesystemssea
}

removed {
  from = module.retail-storesystems.module.subscription.module.virtualnetwork_0.azapi_resource.vnet_storesystemssea

  lifecycle {
    destroy = false
  }
}