# providers.tf — terraform block + AzureRM provider for the Azure SQL lab.
# This lesson provisions a REAL Azure SQL logical server (azurerm_mssql_server),
# one database on it (azurerm_mssql_database) at a chosen DTU/vCore tier, a
# firewall rule opening the server to a client IP, and a failover group with a
# partner server in a second region for HA/DR.
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
