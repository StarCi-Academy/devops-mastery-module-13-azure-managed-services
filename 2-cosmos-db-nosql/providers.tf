# providers.tf — terraform block + AzureRM provider for the Cosmos DB NoSQL lab.
# This lesson provisions a REAL Azure Cosmos DB stack as THREE separate
# resources: an account (azurerm_cosmosdb_account), a SQL database inside it
# (azurerm_cosmosdb_sql_database), and a container inside that database
# (azurerm_cosmosdb_sql_container) with a partition key and provisioned RU/s.
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
# ARM_SUBSCRIPTION_ID (a service principal in Entra ID), or `az login` for a
# human. NEVER hardcode a secret here. `features {}` is mandatory for azurerm.
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
