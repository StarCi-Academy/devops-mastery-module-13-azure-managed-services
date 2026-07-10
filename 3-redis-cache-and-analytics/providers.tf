# providers.tf — terraform block + AzureRM provider for the Azure Managed Redis lesson.
# This lesson provisions a REAL Azure Managed Redis instance (azurerm_managed_redis): the
# tier is a single sku_name string (e.g. Balanced_B0), TLS is forced via the
# default_database client_protocol, eviction via the default_database eviction_policy, and
# network exposure via public_network_access (there is NO separate firewall-rule resource).
# `terraform fmt/validate/init` run offline; `plan/apply` need Azure credentials
# (see .e2e/agnostic/*-require-creds.md).

terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Azure differs from AWS/GCP here: there is NO provider-level "project". Every
# resource is created INSIDE a Resource Group (the lifecycle + scope boundary),
# and the provider authenticates against ONE subscription. Credentials are read
# from env vars in order: ARM_CLIENT_ID / ARM_CLIENT_SECRET / ARM_TENANT_ID /
# ARM_SUBSCRIPTION_ID (a service principal), or `az login` for a human. NEVER
# hardcode a secret here. `features {}` is mandatory for the azurerm provider.
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
