# main.tf — Azure SQL Database, terraform-first.
#
# Mental model: Azure SQL Database is a fully managed PaaS — there is NO VM, NO
# OS, NO patching. You declare a LOGICAL SERVER (azurerm_mssql_server: just an
# administrative + networking container with a public FQDN, NOT a machine) and
# then one or more DATABASES on it (azurerm_mssql_database), each with its own
# SKU (DTU- or vCore-based) and storage. The server denies ALL inbound by
# default: a azurerm_mssql_firewall_rule must open it to a client IP. For HA/DR
# across regions, a azurerm_mssql_failover_group ties the primary server to a
# partner server in another region behind a single read-write listener FQDN.
# This lab builds one primary server + database, opens the firewall to a client
# IP, then adds a secondary server + failover group so you see the full
# server -> database -> firewall -> failover cycle. `terraform fmt/validate/init`
# run offline; `plan/apply` need real Azure credentials.

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
# deletes every resource below: both SQL servers, the database and the failover
# group (so nothing is left billing).
resource "azurerm_resource_group" "lab" {
  name     = "starci-sql-lab-rg"
  location = var.location
  tags     = local.common_tags
}

# The PRIMARY logical SQL Server. This is NOT a VM — it is an administrative
# endpoint (<name>.database.windows.net) that hosts databases. `version = 12.0`
# is the only modern Azure SQL engine. minimum_tls_version forces encrypted
# connections. The admin login/password here is SQL authentication; Entra ID
# (Azure AD) auth is added via the azuread_administrator block in production.
resource "azurerm_mssql_server" "primary" {
  name                         = "starci-sql-primary"
  resource_group_name          = azurerm_resource_group.lab.name
  location                     = azurerm_resource_group.lab.location
  version                      = "12.0"
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password
  minimum_tls_version          = "1.2"
  tags                         = local.common_tags
}

# The DATABASE — the unit you actually pay for and connect to. server_id binds
# it to the primary server. sku_name picks the purchasing model + tier: a
# DTU-based name (Basic/S0/P2) bundles compute + storage + IO into one number;
# a vCore-based name (GP_Gen5_2/BC_Gen5_2/HS_Gen5_2) prices compute and storage
# separately and exposes hardware family + vCore count. zone_redundant spreads
# replicas across availability zones (only on Premium/Business Critical/Hyperscale).
resource "azurerm_mssql_database" "app" {
  name           = "starci-appdb"
  server_id      = azurerm_mssql_server.primary.id
  sku_name       = var.database_sku_name
  max_size_gb    = var.database_max_size_gb
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  zone_redundant = false

  # storage_account_type controls where backups live. Geo (default) replicates
  # backups to the paired region — required for geo-restore. Local is cheapest.
  storage_account_type = "Geo"

  tags = local.common_tags
}

# A FIREWALL RULE — the Azure SQL server denies ALL inbound by default. This rule
# opens the server to a single client IP (your workstation). Without it, a
# connection from outside Azure is rejected at the gateway before authentication.
resource "azurerm_mssql_firewall_rule" "client" {
  name             = "allow-client-ip"
  server_id        = azurerm_mssql_server.primary.id
  start_ip_address = var.client_ip_address
  end_ip_address   = var.client_ip_address
}

# Setting start/end to 0.0.0.0 is the special "Allow Azure services and resources
# to access this server" toggle — it lets Azure-internal services (e.g. an App
# Service in the same tenant) reach the server WITHOUT being a real public IP.
resource "azurerm_mssql_firewall_rule" "azure_services" {
  name             = "allow-azure-services"
  server_id        = azurerm_mssql_server.primary.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# The SECONDARY logical SQL Server in a DIFFERENT region — the failover partner.
# It is an empty server until the failover group replicates the primary database
# into it. Putting it in var.secondary_location is what makes the failover group
# survive a regional outage.
resource "azurerm_mssql_server" "secondary" {
  name                         = "starci-sql-secondary"
  resource_group_name          = azurerm_resource_group.lab.name
  location                     = var.secondary_location
  version                      = "12.0"
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password
  minimum_tls_version          = "1.2"
  tags                         = local.common_tags
}

# The FAILOVER GROUP — ties the primary server to the partner server and keeps
# the listed databases replicated to the secondary. Clients connect to a single
# read-write listener (<group-name>.database.windows.net); on failover Azure
# repoints that FQDN to whichever server is primary, so the connection string
# never changes. Automatic mode fails over without manual action after the grace
# period; data-loss is bounded by grace_minutes.
resource "azurerm_mssql_failover_group" "app" {
  name      = "starci-sql-fog"
  server_id = azurerm_mssql_server.primary.id
  databases = [azurerm_mssql_database.app.id]

  partner_server {
    id = azurerm_mssql_server.secondary.id
  }

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 60
  }

  tags = local.common_tags
}
