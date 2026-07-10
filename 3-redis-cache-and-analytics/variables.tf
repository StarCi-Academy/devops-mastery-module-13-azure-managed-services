# variables.tf — parameterise the subscription, location and the Managed Redis tier.
variable "subscription_id" {
  description = "Azure Subscription ID the provider operates in. The provider authenticates against exactly one subscription; resources live in a Resource Group inside it."
  type        = string
}

variable "location" {
  description = "Azure region all resources are created in (e.g. southeastasia, eastus)."
  type        = string
  default     = "southeastasia"
}

variable "redis_sku_name" {
  description = "Azure Managed Redis SKU tier. Format: <Performance>_<Size>. Balanced_B0 is the smallest/cheapest tier suitable for lab use. Other examples: Balanced_B1, ComputeOptimized_X3, MemoryOptimized_M10."
  type        = string
  default     = "Balanced_B0"
}

variable "lesson" {
  description = "Lesson slug written into the lesson tag so a cleanup script can filter exactly these resources."
  type        = string
  default     = "3-redis-cache-and-analytics"
}
