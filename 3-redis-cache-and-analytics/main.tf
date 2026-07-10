# main.tf — an Azure Managed Redis instance (the successor to Azure Cache for Redis, which
# Azure retired in 2025) inside a Resource Group. azurerm_managed_redis maps to the Azure
# Managed Redis / Redis Enterprise API: the tier is a single sku_name string, TLS and
# eviction live in the default_database block, and there is NO separate firewall-rule
# resource — network exposure is controlled by public_network_access.

locals {
  common_tags = {
    lesson  = var.lesson
    managed = "terraform"
  }
}

# Resource Group — Azure's mandatory lifecycle + scope boundary. Deleting the RG
# deletes the Managed Redis instance and every other child resource in one shot.
resource "azurerm_resource_group" "lab" {
  name     = "starci-redis-lab-rg"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_managed_redis" "main" {
  name                = "starci-redis-lab"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location

  # sku_name is the WHOLE tier in one string: <Performance>_<Size>. Performance is one of
  # Balanced / ComputeOptimized / FlashOptimized / MemoryOptimized; Balanced_B0 is the
  # smallest, cheapest instance. There is NO sku_name + family + capacity triple like the
  # legacy azurerm_redis_cache — this single string selects both the class and the size.
  sku_name = var.redis_sku_name

  # high_availability_enabled (default true) provisions a replica with automatic failover
  # and the SLA. Stated explicitly so the intent is on the page; turn it off only for a
  # throwaway single-node dev instance.
  high_availability_enabled = true

  # public_network_access = "Enabled" exposes the instance on a public endpoint so the lab
  # can reach it. In production set "Disabled" and reach it through a private endpoint.
  # Managed Redis has no separate firewall-rule resource — this toggle plus private
  # endpoints / Entra ID auth are how you gate access.
  public_network_access = "Enabled"

  # default_database configures the built-in database (DB 0).
  default_database {
    # client_protocol = "Encrypted" forces TLS on the single data port (10000): a plaintext
    # client is refused. This replaces the legacy non_ssl_port_enabled + 6379/6380 split.
    client_protocol = "Encrypted"

    # access_keys_authentication_enabled = true exposes primary/secondary access keys so a
    # client can authenticate with a password (redis-cli -a <key>). The default is false,
    # which allows ONLY Microsoft Entra ID token auth. Keys are convenient but static
    # secrets you must rotate; prefer Entra ID in production.
    access_keys_authentication_enabled = true

    # eviction_policy controls what Redis drops when memory is full. AllKeysLRU evicts the
    # least-recently-used key across ALL keys (right for a pure cache). Values are
    # PascalCase here (AllKeysLRU / VolatileLRU / NoEviction …), not the legacy allkeys-lru.
    eviction_policy = "AllKeysLRU"
  }

  tags = local.common_tags
}
