# outputs.tf — values printed after apply (read with `terraform output`).
output "resource_group_name" {
  description = "Name of the Resource Group that scopes every resource in this lab."
  value       = azurerm_resource_group.lab.name
}

output "cosmos_account_name" {
  description = "Globally unique Cosmos DB account name (becomes <name>.documents.azure.com)."
  value       = azurerm_cosmosdb_account.lab.name
}

output "cosmos_endpoint" {
  description = "The HTTPS endpoint used to connect to the Cosmos DB account."
  value       = azurerm_cosmosdb_account.lab.endpoint
}

output "cosmos_consistency_level" {
  description = "The default consistency level configured on the account."
  value       = var.consistency_level
}

output "sql_database_name" {
  description = "Name of the SQL (Core) database created inside the account."
  value       = azurerm_cosmosdb_sql_database.lab.name
}

output "sql_container_name" {
  description = "Name of the container created inside the database."
  value       = azurerm_cosmosdb_sql_container.lab.name
}

output "container_partition_key" {
  description = "The partition key path Cosmos hashes to shard documents across physical partitions."
  value       = var.container_partition_key_path
}

# The primary key is a SECRET — marked sensitive so Terraform does not print it
# in the CLI. Read it explicitly with `terraform output -raw cosmos_primary_key`.
output "cosmos_primary_key" {
  description = "Primary master key for the Cosmos DB account (sensitive)."
  value       = azurerm_cosmosdb_account.lab.primary_key
  sensitive   = true
}
