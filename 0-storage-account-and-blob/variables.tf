# variables.tf — tham so hoa vi tri, tien to ten, va tier mac dinh cua blob.
variable "location" {
  description = "Azure region noi Resource Group + Storage Account ton tai (vd southeastasia, eastus)."
  type        = string
  default     = "southeastasia"
}

variable "name_prefix" {
  description = "Tien to dat truoc ten RG va storage account de tranh trung khi nhieu hoc vien chung 1 subscription. Chi chu thuong + so."
  type        = string
  default     = "starci"
}

variable "storage_account_suffix" {
  description = "Hau to ngau nhien cho ten storage account — ten storage account phai DUY NHAT toan cau (3-24 ky tu, chi chu thuong + so)."
  type        = string
  default     = "blob01"
}

variable "blob_access_tier" {
  description = "Access tier cho blob upload mau: Hot (truy cap thuong xuyen), Cool, hoac Archive (re nhat, can rehydrate)."
  type        = string
  default     = "Cool"
}
