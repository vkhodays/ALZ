<!-- BEGIN_TF_DOCS -->
# ALZ.LandingZones.Apps

## Overview

This Terraform repository uses the internal `Terraform.LandingZones` module to provision Azure Subscriptions with some pre-configured defaults, such as:
- A base Virtual Network (or multiple if desired) with a given CIDR range
- A Service Principal and associated Connection within Azure DevOps for the provided project
- A Terraform State bucket which can be used within Azure DevOps pipelines
- An Azure DevOps Variable Group containing details for the Terraform State bucket and Subscription IDs

**Note:** Within this repository, only **Application Subscriptions** (those which are intended for application services) should be defined. For **Platform Subscriptions**, use the `ALZ.LandingZones.Platform` repository.

## Updating Docs

The `terraform-docs` utility is used to generate this README. Follow the below steps to update:
1. Make changes to the `.terraform-docs.yml` file
2. Fetch the `terraform-docs` binary (https://terraform-docs.io/user-guide/installation/)
3. Run `terraform-docs markdown table --output-file ${PWD}/README.md --output-mode inject terraform/`

## Release Process

The `Terraform.LandingZones` module is automatically tagged upon merge to the `main` branch. When a new version of the module is released, the `ALZ.LandingZones.Apps` repository should be updated to use the new version. This is done by updating the `source` parameter in the `main.tf` file to point to the new version.

Any changes to Landing Zones should be performed on a feature branch and merged to the `main` branch once approved. The `main` branch is protected and requires at least one approval before merging. The below diagram shows the release process for an Application Landing Zone:

![apps](apps.png)

## Required Pipeline Variables

The following variables are required to be set before running Terraform:
- platform_environment: All Application Landing Zone environments (`dev`, `pre`, `prd`) are deployed to the **Prod** Azure Tenant.
- core_storage_account_name: Read access is required to the Core Storage Account and the Terraform State within it. The State file contains the IDs for the Azure VWAN Hubs (provisioned by `ALZ.Connectivity`), which are required for connecting the Landing Zone to the Hub Network.
- devops_org_name: The name of the Azure DevOps organisation all projects are located.
- devops_pat: An Azure DevOps Personal Access Token for authentication.

## Landing Zone Variables

The below code is an example of how to define an Application Landing Zone in the `main.tf` file.

```hcl
module "service-name" {
  source = "git::https://dev.azure.com/appvia/Azure%20Landing%20Zones/_git/Terraform.LandingZones?ref=v1.0.0"

  platform_environment = var.platform_environment # Passed via pipeline variable
  app_environment      = var.app_environment      # Passed via pipeline variable
  subscription_ids     = local.subscription_ids   # Read from core remote state, used to create the Variable Group

  # Multiple virtual networks can be defined here and built in the `dev`, `pre` and `prd` Landing Zones
  virtual_networks = {
    main = {                                                   # This is the name of the virtual network (can be called anything)
      azurerm_virtual_hub_id = local.southeastasia_virtual_hub_id # Read from core remote state
      address_space = {
        dev = ["10.30.1.0/24"] # The address space(s) for the `main` virtual network in the `dev` Landing Zone (Prod Tenant)
        pre = ["10.30.2.0/24"] # The address space(s) for the `main` virtual network in the `pre` Landing Zone (Prod Tenant)
        prd = ["10.30.3.0/24"] # The address space(s) for the `main` virtual network in the `prd` Landing Zone (Prod Tenant)
      }
    }
  }

  private_dns_zones = data.terraform_remote_state.core.outputs.azurerm_private_dns_zone # Read from core remote state, used to create the Private DNS Links

  rbac = {
    template_name = "standard"
    create_groups = true # Create custom ALZ RBAC groups for the Landing Zone
  }

  devops_project_name = "Azure Landing Zones" # The name of the Azure DevOps project where the Service Connection and Variable Group will be created
  management_group    = "internal"                             # The name of the Management Group where the Subscription will be created (either "internal" or "external")
  subscription_name   = "service-name"                         # A unique name (across the Tenant) for the Subscription to be created
  subscription_tags = {
    WorkloadName        = "ALZ.Core"
    DataClassification  = "General"
    BusinessCriticality = "Mission-critical"
    BusinessUnit        = "Platform Operations"
    OperationsTeam      = "Platform Operations"
  }
}
```
<!-- END_TF_DOCS -->