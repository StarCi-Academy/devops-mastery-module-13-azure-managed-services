# main.tf — Azure Managed Redis (new generation, replaces legacy Azure Cache for Redis)
# behind a Resource Group. Azure Cache for Redis is retired as of 2025; the replacement
# is azurerm_managed_redis which maps to the Azure Managed Redis / Redis Enterprise API.
# Tier is sku_name (Balanced_B0 is the smallest / cheapest tier for lab use).
# Eviction policy lives in the default_database block.

locals {
  common_tags = {
    lesson  = var.lesson
    managed = "terraform"
  }
}

# Resource Group — the mandatory lifecycle + scope boundary on Azure. Deleting the
# RG deletes the Managed Redis instance and every other child resource in one shot.
resource "azurerm_resource_group" "lab" {
  name     = "starci-redis-lab-rg"
  location = var.location
  tags     = local.common_tags
}

# azurerm_managed_redis — the new Azure Managed Redis instance (Redis Enterprise API).
# sku_name selects the performance tier: Balanced (general purpose), ComputeOptimized,
# FlashOptimized, MemoryOptimized. B0 is the smallest/cheapest balanced instance.
# public_network_access = "Enabled" is required for connectivity without a private
# endpoint (suitable for lab/demo use).
resource "azurerm_managed_redis" "main" {
  name                  = "starci-redis-lab"
  resource_group_name   = azurerm_resource_group.lab.name
  location              = azurerm_resource_group.lab.location
  sku_name              = var.redis_sku_name # e.g. Balanced_B0
  public_network_access = "Enabled"

  # default_database configures the built-in database (DB 0). Eviction policy
  # controls what Redis does when memory is full: allkeys-lru evicts the least-
  # recently-used key across all keys (no TTL required).
  default_database {
    eviction_policy = "AllKeysLRU"
  }

  tags = local.common_tags
}
