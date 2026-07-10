# Read the identity the provider is using — to fetch subscription/tenant as proof of auth.
data "azurerm_client_config" "current" {
}

# Resource Group — lifecycle + scope boundary. The storage account (and every resource) MUST live inside one RG.
resource "azurerm_resource_group" "lab" {
  name     = "${var.name_prefix}-storage-rg"
  location = var.location

  tags = {
    course = "devops-mastery"
    module = "azure-managed-services"
  }
}

# Storage Account — the "account" holding blob/file/queue/table. The name must be GLOBALLY UNIQUE (global namespace),
# 3-24 chars, lowercase letters + digits only. account_tier + account_replication_type decide performance + durability.
#   - account_tier = Standard (HDD-backed, cheap) or Premium (SSD, low latency).
#   - account_replication_type = LRS (3 copies in one datacenter, cheapest) ... GRS (cross-region replication).
#   - account_kind = StorageV2 (default, full tier + lifecycle support) — do NOT use the legacy kind.
#   - access_tier (ACCOUNT level) = Hot/Cool: default tier for blobs that do not declare their own tier.
# blob_properties enables versioning + soft delete: this is the key production differentiator.
resource "azurerm_storage_account" "blob" {
  name                     = "${var.name_prefix}${var.storage_account_suffix}"
  resource_group_name      = azurerm_resource_group.lab.name
  location                 = azurerm_resource_group.lab.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  # Security hardening: HTTPS only, TLS 1.2 minimum, NO anonymous public blob/container access.
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  blob_properties {
    # versioning_enabled: every overwrite of a blob -> creates a new version (the old one is recoverable).
    versioning_enabled = true

    # soft delete: a deleted blob is retained for 7 days for recovery (guards against accidental deletion).
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  tags = {
    course = "devops-mastery"
    module = "azure-managed-services"
  }
}

# Storage Container — the top-level "folder" holding blobs inside the storage account.
# container_access_type = private: NO anonymous access (only credentialed callers can read).
resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = azurerm_storage_account.blob.name
  container_access_type = "private"
}

# A sample blob (Block blob) — pushes content into the container and sets an access tier just for this blob.
# access_tier at the BLOB level overrides the account default access_tier: e.g. Cool for a rarely-read file.
resource "azurerm_storage_blob" "sample" {
  name                   = "hello.txt"
  storage_account_name   = azurerm_storage_account.blob.name
  storage_container_name = azurerm_storage_container.data.name
  type                   = "Block"
  access_tier            = var.blob_access_tier
  source_content         = "hello from terraform on azure blob storage\n"
  content_type           = "text/plain"
}

# Management policy — automates blob lifecycle by AGE. This is how you cut storage cost at scale:
# new blob -> Hot; after 30 days unmodified -> Cool; after 90 days -> Archive (cheapest); after 365 days -> delete.
# The rule applies only to blockBlob (Archive supports block blobs only). prefix_match scopes it by path.
resource "azurerm_storage_management_policy" "lifecycle" {
  storage_account_id = azurerm_storage_account.blob.id

  rule {
    name    = "tier-and-expire"
    enabled = true

    filters {
      prefix_match = ["data/"]
      blob_types   = ["blockBlob"]
    }

    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 30
        tier_to_archive_after_days_since_modification_greater_than = 90
        delete_after_days_since_modification_greater_than          = 365
      }
    }
  }
}
