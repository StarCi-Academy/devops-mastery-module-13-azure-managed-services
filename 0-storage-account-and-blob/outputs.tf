# outputs.tf — gia tri in ra sau apply.
output "subscription_id" {
  description = "GUID cua subscription hien tai (don vi billing)."
  value       = data.azurerm_client_config.current.subscription_id
}

output "tenant_id" {
  description = "Tenant ID (Entra ID directory) ma provider dang xac thuc toi."
  value       = data.azurerm_client_config.current.tenant_id
}

output "storage_account_name" {
  description = "Ten storage account (duy nhat toan cau) vua tao."
  value       = azurerm_storage_account.blob.name
}

output "primary_blob_endpoint" {
  description = "URL endpoint cua blob service (vd https://<name>.blob.core.windows.net/)."
  value       = azurerm_storage_account.blob.primary_blob_endpoint
}

output "container_name" {
  description = "Ten container chua blob."
  value       = azurerm_storage_container.data.name
}

output "blob_url" {
  description = "URL day du cua blob mau hello.txt."
  value       = azurerm_storage_blob.sample.url
}

output "blob_access_tier" {
  description = "Access tier hien tai cua blob mau (Hot/Cool/Archive)."
  value       = azurerm_storage_blob.sample.access_tier
}
