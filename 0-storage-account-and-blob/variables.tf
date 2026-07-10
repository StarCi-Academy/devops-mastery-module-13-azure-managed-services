# variables.tf — parameterize the location, name prefix, and the sample blob's default tier.
variable "location" {
  description = "Azure region where the Resource Group + Storage Account live (e.g. southeastasia, eastus)."
  type        = string
  default     = "southeastasia"
}

variable "name_prefix" {
  description = "Prefix placed before the RG and storage account names to avoid collisions when many learners share one subscription. Lowercase letters + digits only."
  type        = string
  default     = "starci"
}

variable "storage_account_suffix" {
  description = "Random suffix for the storage account name — the storage account name must be GLOBALLY UNIQUE (3-24 chars, lowercase letters + digits only)."
  type        = string
  default     = "blob01"
}

variable "blob_access_tier" {
  description = "Access tier for the sample uploaded blob: Hot (frequent access), Cool, or Archive (cheapest, needs rehydration)."
  type        = string
  default     = "Cool"
}
