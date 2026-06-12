# providers.tf — Azure Storage Account + Blob: access tier (Hot/Cool/Archive), lifecycle, versioning.
# Day la bai dau cua module Azure managed services. Storage Account la "tai khoan" chua blob/file/queue/table;
# trong bai nay ta tap trung Blob: tao container, day mot blob, dat access tier, bat versioning,
# va dung management policy de tu dong chuyen tier Hot -> Cool -> Archive -> delete theo tuoi blob.
# Provider azurerm xac thuc qua Entra ID (service principal qua ARM_* hoac az login). KHONG hardcode credential.
terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

# features {} la block BAT BUOC cua azurerm. provider dò credential theo thu tu:
#   1. bien moi truong ARM_CLIENT_ID/ARM_CLIENT_SECRET/ARM_TENANT_ID/ARM_SUBSCRIPTION_ID (service principal)
#   2. Azure CLI da `az login` (developer local)
#   3. Managed Identity (khi chay tren tai nguyen Azure)
provider "azurerm" {
  features {}
}
