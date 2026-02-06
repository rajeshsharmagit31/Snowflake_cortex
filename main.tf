provider "snowflake" {
  account       = var.snowflake_account
  user          = var.snowflake_user
  role          = var.snowflake_role
  authenticator = var.snowflake_authenticator

  warehouse = var.snowflake_warehouse
  database  = var.snowflake_database
  schema    = var.snowflake_schema
}
