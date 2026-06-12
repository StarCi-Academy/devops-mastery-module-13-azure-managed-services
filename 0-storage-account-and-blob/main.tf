# Doc danh tinh ma provider dang dung — de lay subscription/tenant lam bang chung auth.
data "azurerm_client_config" "current" {
}

# Resource Group — boundary lifecycle + scope. Storage account (va moi resource) PHAI nam trong 1 RG.
resource "azurerm_resource_group" "lab" {
  name     = "${var.name_prefix}-storage-rg"
  location = var.location

  tags = {
    course = "devops-mastery"
    module = "azure-managed-services"
  }
}

# Storage Account — "tai khoan" chua blob/file/queue/table. Ten phai DUY NHAT toan cau (global namespace),
# 3-24 ky tu, chi chu thuong + so. account_tier + account_replication_type quyet dinh hieu nang + do ben.
#   - account_tier = Standard (HDD-backed, re) hoac Premium (SSD, do tre thap).
#   - account_replication_type = LRS (3 ban trong 1 datacenter, re nhat) ... GRS (nhan ban lien vung).
#   - account_kind = StorageV2 (mac dinh, ho tro day du tier + lifecycle) — KHONG dung loai cu.
#   - access_tier (cap ACCOUNT) = Hot/Cool: tier mac dinh cho blob khong khai bao tier rieng.
# blob_properties bat versioning + soft delete: day la diem khac biet quan trong cho production.
resource "azurerm_storage_account" "blob" {
  name                     = "${var.name_prefix}${var.storage_account_suffix}"
  resource_group_name      = azurerm_resource_group.lab.name
  location                 = azurerm_resource_group.lab.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  # Siet bao mat: chi cho HTTPS, TLS toi thieu 1.2, KHONG cho blob/container public an danh.
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  blob_properties {
    # versioning_enabled: moi lan ghi de blob -> tao 1 version moi (khoi phuc duoc ban cu).
    versioning_enabled = true

    # soft delete: blob bi xoa van giu lai 7 ngay de khoi phuc (chong xoa nham).
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

# Storage Container — "thu muc" cap cao nhat chua blob trong storage account.
# container_access_type = private: KHONG cho truy cap an danh (chi co credential moi doc duoc).
resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = azurerm_storage_account.blob.name
  container_access_type = "private"
}

# Mot blob mau (Block blob) — day noi dung len container, dat access tier rieng cho rieng blob nay.
# access_tier o cap BLOB ghi de access_tier mac dinh cua account: vi du de Cool cho file it doc.
resource "azurerm_storage_blob" "sample" {
  name                   = "hello.txt"
  storage_account_name   = azurerm_storage_account.blob.name
  storage_container_name = azurerm_storage_container.data.name
  type                   = "Block"
  access_tier            = var.blob_access_tier
  source_content         = "hello from terraform on azure blob storage\n"
  content_type           = "text/plain"
}

# Management policy — tu dong hoa vong doi blob theo TUOI. Day la cach giam chi phi luu tru o quy mo lon:
# blob moi -> Hot; sau 30 ngay khong sua -> Cool; sau 90 ngay -> Archive (re nhat); sau 365 ngay -> xoa.
# Quy tac chi ap cho blockBlob (Archive chi ho tro block blob). prefix_match gioi han pham vi theo duong dan.
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
