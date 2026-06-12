# variables.tf — parameterise subscription, regions, admin login, SKU and client IP.
variable "subscription_id" {
  description = "Azure Subscription ID the provider operates in. The provider authenticates against exactly one subscription; resources live in a Resource Group inside it."
  type        = string
}

variable "location" {
  description = "Primary Azure region for the SQL server + database (e.g. southeastasia, eastus)."
  type        = string
  default     = "southeastasia"
}

variable "secondary_location" {
  description = "Secondary Azure region for the partner SQL server in the failover group. MUST differ from var.location so failover survives a regional outage."
  type        = string
  default     = "eastasia"
}

variable "administrator_login" {
  description = "SQL authentication admin login for the logical server. Must NOT be a reserved name like 'admin', 'sa', 'root' or 'azure_superuser'."
  type        = string
  default     = "sqladmin"
}

variable "administrator_login_password" {
  description = "Password for administrator_login. Must comply with Azure's password policy (>=8 chars, 3 of 4 categories). Pass via TF_VAR_administrator_login_password env var; NEVER hardcode."
  type        = string
  sensitive   = true
}

variable "database_sku_name" {
  description = "SKU of the database. DTU-based: Basic, S0..S12, P1..P15. vCore-based: GP_Gen5_2 (General Purpose), BC_Gen5_2 (Business Critical), HS_Gen5_2 (Hyperscale), GP_S_Gen5_1 (serverless). DTU bundles compute+IO; vCore prices compute and storage separately."
  type        = string
  default     = "S0"
}

variable "database_max_size_gb" {
  description = "Max size of the database in GB. Must be within the limit of the chosen SKU (Basic caps at 2GB; S0 at 250GB)."
  type        = number
  default     = 50
}

variable "client_ip_address" {
  description = "Public IP allowed through the SQL firewall (your workstation's egress IP, find via `curl ifconfig.me`). The default Azure SQL firewall denies ALL inbound until a rule like this opens it."
  type        = string
  default     = "203.0.113.10"
}

variable "lesson" {
  description = "Lesson slug written into the lesson tag so a cleanup script can filter exactly these resources."
  type        = string
  default     = "1-azure-sql-database"
}
