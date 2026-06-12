# providers.tf — terraform block + AzureRM provider for the Azure Cache for Redis
# lesson. This lesson provisions a REAL managed Redis instance: an azurerm_redis_cache
# (tier/capacity via sku_name + family + capacity, TLS-only, eviction policy via the
# redis_configuration block) and an azurerm_redis_firewall_rule that allows a single
# operator IP range. Analytics (Azure Synapse) is intentionally DEFERRED — see §2.2.
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
