# variables.tf — parameterise subscription, location, names, RU/s, partition key
# and consistency level for the Cosmos DB NoSQL lab.
variable "subscription_id" {
  description = "Azure Subscription ID the provider operates in. The provider authenticates against exactly one subscription; resources live in a Resource Group inside it."
  type        = string
}

variable "location" {
  description = "Azure region the Resource Group and Cosmos DB account are created in (e.g. southeastasia, eastus). This is the account's write region (failover_priority 0)."
  type        = string
  default     = "southeastasia"
}

variable "name_prefix" {
  description = "Prefix for the resource group name. Lowercase letters + digits only."
  type        = string
  default     = "starci"
}

variable "cosmos_account_suffix" {
  description = "Suffix appended to the Cosmos DB account name. The account name must be GLOBALLY UNIQUE (3-44 chars, lowercase letters, digits and hyphens) because it becomes <name>.documents.azure.com."
  type        = string
  default     = "cosmos01"
}

variable "consistency_level" {
  description = "Default consistency level for the account. One of BoundedStaleness, Eventual, Session, Strong, ConsistentPrefix. Session is the Cosmos default and the right balance for most apps."
  type        = string
  default     = "Session"
}

variable "database_throughput" {
  description = "Provisioned throughput (RU/s) at the DATABASE level, shared by all containers. Must be a multiple of 100; 400 is the minimum for a shared-throughput database."
  type        = number
  default     = 400
}

variable "container_partition_key_path" {
  description = "JSON path of the container partition key (e.g. /userId). Cosmos spreads documents across physical partitions by HASHING this value; pick a high-cardinality, even-access field."
  type        = string
  default     = "/userId"
}

variable "container_max_throughput" {
  description = "Maximum autoscale throughput (RU/s) at the CONTAINER level. Cosmos scales between 10% and this value. Must be between 1000 and 1000000, in increments of 1000."
  type        = number
  default     = 1000
}

variable "free_tier_enabled" {
  description = "Enable the Cosmos DB Free Tier (first 1000 RU/s + 25 GB free). Only ONE free-tier account is allowed per subscription; a second apply with this true will fail."
  type        = bool
  default     = false
}

variable "lesson" {
  description = "Lesson slug written into the lesson tag so a cleanup script can filter exactly these resources."
  type        = string
  default     = "2-cosmos-db-nosql"
}
