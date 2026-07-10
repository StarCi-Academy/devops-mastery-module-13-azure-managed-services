# providers.tf — Azure Storage Account + Blob: access tier (Hot/Cool/Archive), lifecycle, versioning.
# This is the opening lesson of the Azure managed services module. A Storage Account is the "account" that holds blob/file/queue/table;
# in this lesson we focus on Blob: create a container, push one blob, set an access tier, enable versioning,
# and use a management policy to auto-move tiers Hot -> Cool -> Archive -> delete by blob age.
# The azurerm provider authenticates via Entra ID (service principal through ARM_* or az login). Never hardcode credentials.
terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

# features {} is the MANDATORY azurerm block. The provider resolves credentials in this order:
#   1. environment variables ARM_CLIENT_ID/ARM_CLIENT_SECRET/ARM_TENANT_ID/ARM_SUBSCRIPTION_ID (service principal)
#   2. Azure CLI after `az login` (developer local)
#   3. Managed Identity (when running on an Azure resource)
provider "azurerm" {
  features {}
}
