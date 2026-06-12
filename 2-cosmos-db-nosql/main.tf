# main.tf — Cosmos DB NoSQL (SQL API), terraform-first.
#
# Mental model: a Cosmos DB NoSQL data store is NOT one resource. It is THREE
# separate resources, nested by name reference:
#   1. azurerm_cosmosdb_account        — the global database account (endpoint,
#      consistency policy, geo-replication, billing boundary).
#   2. azurerm_cosmosdb_sql_database   — a SQL (Core) database inside the account.
#   3. azurerm_cosmosdb_sql_container  — a container (collection) inside the
#      database, with a PARTITION KEY and provisioned RU/s.
# Throughput (RU/s) and the partition key are the two performance levers. This
# lab provisions the account, a shared-throughput database, and one container
# partitioned by /userId. `terraform fmt/validate/init` run offline; `plan/apply`
# need real Azure credentials.

locals {
  # Every resource carries these tags so a tag-filtered cleanup sweeps exactly
  # this lesson's resources. Azure tags are free-form key/value strings.
  common_tags = {
    course     = "devops-mastery"
    lesson     = var.lesson
    managed-by = "terraform"
  }
}

# The Resource Group — Azure's hard lifecycle + scope boundary. Deleting it
# deletes the Cosmos account, the database and the container in one shot (so no
# orphaned account keeps billing RU/s).
resource "azurerm_resource_group" "lab" {
  name     = "${var.name_prefix}-cosmos-lab-rg"
  location = var.location
  tags     = local.common_tags
}

# RESOURCE 1 — the Cosmos DB ACCOUNT. This is the global endpoint
# (<name>.documents.azure.com) and the unit of geo-replication, consistency and
# billing. offer_type is always "Standard"; kind "GlobalDocumentDB" selects the
# SQL (Core / NoSQL) API. consistency_policy sets the DEFAULT read consistency.
# geo_location lists the regions data is replicated to; failover_priority 0 is
# the write region.
resource "azurerm_cosmosdb_account" "lab" {
  name                = "${var.name_prefix}-${var.cosmos_account_suffix}"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  free_tier_enabled = var.free_tier_enabled

  consistency_policy {
    consistency_level = var.consistency_level
  }

  geo_location {
    location          = azurerm_resource_group.lab.location
    failover_priority = 0
  }

  tags = local.common_tags
}

# RESOURCE 2 — the SQL DATABASE, created INSIDE the account by name reference
# (account_name). throughput here is SHARED by every container in the database
# (a cost-efficient model for many small containers). It must be a multiple of
# 100 and set at creation time.
resource "azurerm_cosmosdb_sql_database" "lab" {
  name                = "appdb"
  resource_group_name = azurerm_cosmosdb_account.lab.resource_group_name
  account_name        = azurerm_cosmosdb_account.lab.name
  throughput          = var.database_throughput
}

# RESOURCE 3 — the CONTAINER (collection), created INSIDE the database. The
# PARTITION KEY (partition_key_paths) is the single most important design choice:
# Cosmos hashes this value to spread documents across physical partitions for
# horizontal scale. partition_key_version 2 supports large (hierarchical) keys.
# autoscale_settings.max_throughput gives the container its OWN dedicated,
# auto-scaling RU/s (overriding the database's shared throughput for this one
# container).
resource "azurerm_cosmosdb_sql_container" "lab" {
  name                  = "events"
  resource_group_name   = azurerm_cosmosdb_account.lab.resource_group_name
  account_name          = azurerm_cosmosdb_account.lab.name
  database_name         = azurerm_cosmosdb_sql_database.lab.name
  partition_key_paths   = [var.container_partition_key_path]
  partition_key_version = 2

  autoscale_settings {
    max_throughput = var.container_max_throughput
  }

  # Unique key: enforce that (within a partition) /eventId is unique — the Cosmos
  # equivalent of a unique constraint. Set at container creation, immutable after.
  unique_key {
    paths = ["/eventId"]
  }
}
