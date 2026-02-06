variable "snowflake_account" {
  type        = string
  description = "Snowflake account identifier (e.g., KJNBWXI-ZW90463)."
}

variable "snowflake_user" {
  type        = string
  description = "Snowflake username used by Terraform."
}

variable "snowflake_role" {
  type        = string
  description = "Snowflake role used by Terraform."
  default     = "ACCOUNTADMIN"
}

variable "snowflake_authenticator" {
  type        = string
  description = "Snowflake authenticator (e.g., externalbrowser, oauth, snowflake)."
  default     = "externalbrowser"
}

variable "snowflake_warehouse" {
  type        = string
  description = "Default warehouse (optional)."
  default     = null
}

variable "snowflake_database" {
  type        = string
  description = "Default database (optional)."
  default     = null
}

variable "snowflake_schema" {
  type        = string
  description = "Default schema (optional)."
  default     = null
}
