# outputs.tf — values printed after apply (read with `terraform output`).
output "resource_group_name" {
  description = "Name of the Resource Group that scopes every resource in this lab."
  value       = azurerm_resource_group.lab.name
}

output "primary_server_fqdn" {
  description = "Fully-qualified domain name of the primary SQL server (<name>.database.windows.net)."
  value       = azurerm_mssql_server.primary.fully_qualified_domain_name
}

output "database_name" {
  description = "Name of the application database created on the primary server."
  value       = azurerm_mssql_database.app.name
}

output "database_sku" {
  description = "SKU (tier) the database runs at — DTU-based (e.g. S0) or vCore-based (e.g. GP_Gen5_2)."
  value       = azurerm_mssql_database.app.sku_name
}

output "failover_group_listener_fqdn" {
  description = "Read-write listener FQDN of the failover group. Use THIS in connection strings so the endpoint survives a failover."
  value       = "${azurerm_mssql_failover_group.app.name}.database.windows.net"
}
