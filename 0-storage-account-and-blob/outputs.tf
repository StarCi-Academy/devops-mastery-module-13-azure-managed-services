# outputs.tf — values printed after apply.
output "subscription_id" {
  description = "GUID of the current subscription (billing unit)."
  value       = data.azurerm_client_config.current.subscription_id
}

output "tenant_id" {
  description = "Tenant ID (Entra ID directory) the provider authenticates against."
  value       = data.azurerm_client_config.current.tenant_id
}

output "storage_account_name" {
  description = "Name of the (globally unique) storage account just created."
  value       = azurerm_storage_account.blob.name
}

output "primary_blob_endpoint" {
  description = "Blob service endpoint URL (e.g. https://<name>.blob.core.windows.net/)."
  value       = azurerm_storage_account.blob.primary_blob_endpoint
}

output "container_name" {
  description = "Name of the container holding the blob."
  value       = azurerm_storage_container.data.name
}

output "blob_url" {
  description = "Full URL of the sample blob hello.txt."
  value       = azurerm_storage_blob.sample.url
}

output "blob_access_tier" {
  description = "Current access tier of the sample blob (Hot/Cool/Archive)."
  value       = azurerm_storage_blob.sample.access_tier
}
