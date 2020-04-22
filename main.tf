
terraform {
  required_version = ">=0.12"
  backend "local" {
    path = "./.state/terraform.tfstate"
  }
}

provider "postgresql" {
  host = "localhost"
  port = 5432
  # Don't do this for real scenarios :)
  username = "admin"
  password = "admin"
}

provider "vault" {
  address = "http://localhost:8200"
}

module "db_utopia" {
  source = "./modules/psql"

  db_name = "utopia"
}

module "vault" {
  source = "./modules/vault"

  db_name = module.db_utopia.db_name
  vault_db_username = module.db_utopia.db_user_admin_name
  vault_db_password = module.db_utopia.db_user_admin_password
  db_read_role = module.db_utopia.db_read_role
  db_app_role = module.db_utopia.db_app_role
  db_admin_role = module.db_utopia.db_admin_role
}