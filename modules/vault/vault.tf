
resource "vault_mount" "db" {
  path = "db-${var.db_name}"
  type = "database"
}

resource "vault_database_secret_backend_connection" "db" {
  backend = vault_mount.db.path
  name = var.db_name
  verify_connection = true
  allowed_roles = [
    vault_database_secret_backend_role.db_read_role.name,
    vault_database_secret_backend_role.db_app_role.name,
    vault_database_secret_backend_role.db_admin_role.name
  ]

  postgresql {
    connection_url = "postgres://{{username}}:{{password}}@postgres:5432/${var.db_name}?sslmode=require"
  }

  data = {
    username = var.vault_db_username
    password = var.vault_db_password
  }
}

resource "vault_database_secret_backend_role" "db_read_role" {
  backend = vault_mount.db.path
  creation_statements = [
    "CREATE USER \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'",
    "GRANT ${var.db_read_role} TO \"{{name}}\"",
  ]
  db_name = var.db_name
  name = "${var.db_name}_read_role"
  default_ttl = 3600
  max_ttl = 3600
}

resource "vault_database_secret_backend_role" "db_app_role" {
  backend = vault_mount.db.path
  creation_statements = [
    "CREATE USER \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'",
    "GRANT ${var.db_app_role} TO \"{{name}}\"",
  ]
  db_name = var.db_name
  name = "${var.db_name}_app_role"
  default_ttl = 3600
  max_ttl = 3600
}

resource "vault_database_secret_backend_role" "db_admin_role" {
  backend = vault_mount.db.path
  creation_statements = [
    "CREATE USER \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'",
    "GRANT ${var.db_admin_role} TO \"{{name}}\"",
  ]
  db_name = var.db_name
  name = "${var.db_name}_admin_role"
  default_ttl = 3600
  max_ttl = 3600
}