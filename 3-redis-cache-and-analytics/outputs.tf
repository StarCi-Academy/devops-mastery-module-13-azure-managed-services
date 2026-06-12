# outputs.tf — values printed after apply (read with `terraform output`).
output "resource_group_name" {
  description = "Name of the Resource Group that scopes every resource in this lab."
  value       = azurerm_resource_group.lab.name
}

output "redis_hostname" {
  description = "The hostname of the Managed Redis instance — connect with redis-cli -h <hostname> -p <port> --tls."
  value       = azurerm_managed_redis.main.hostname
}

output "redis_primary_access_key" {
  description = "Primary access key for DB 0 (the password). Marked sensitive so it is not printed in plan/apply logs."
  value       = azurerm_managed_redis.main.default_database[0].primary_access_key
  sensitive   = true
}

output "redis_sku" {
  description = "Effective SKU tier of the deployed Managed Redis instance."
  value       = azurerm_managed_redis.main.sku_name
}
