variable "core_storage_account_name" {
  type        = string
  description = "Sets the name of the storage account to retrieve the core tfstate outputs from"
}

variable "devops_org_name" {
  type        = string
  description = "The name of the Azure DevOps organisation"
  default     = "RalphLauren"
}

variable "devops_pat" {
  type        = string
  description = "The Azure DevOps personal access token"
  sensitive   = true
  default     = null
}

variable "github_token" {
  type        = string
  description = "A GitHub OAuth / Personal Access Token"
  sensitive   = true
  default     = null
}

variable "github_owner" {
  type        = string
  description = "The GitHub organization"
  default     = "##GITHUB_ORGANSATION_NAME##"
}

variable "platform_environment" {
  type        = string
  description = "The platform environment (tenant)"
  default     = "Test"

  validation {
    condition = contains(
      ["Test", "Prod"],
      var.platform_environment
    )
    error_message = "Error: platform_environment must be one of: Test, Prod."
  }
}

variable "app_environment" {
  type        = string
  description = "The subscription environment to deploy"
  default     = "npd"

  validation {
    condition = contains(
      ["npd", "prd"],
      var.app_environment
    )
    error_message = "Error: app_environment must be one of: npd, prd."
  }
}

variable "billing_scope" {
  type        = string
  description = "The billing scope for the subscription"
  default     = "/providers/Microsoft.Billing/billingAccounts/1d2eb514-b0a9-54a1-14c9-9675374f6f5a:75489ef1-7aa8-4587-9a38-f3e37c247b9b_2019-05-31/billingProfiles/7HDL-VSKN-BG7-PGB/invoiceSections/GCXM-DOXN-PJA-PGB"
}

variable "use_oidc" {
  type        = bool
  description = "Use OpenID Connect to authenticate to AzureRM"
  default     = false
}
