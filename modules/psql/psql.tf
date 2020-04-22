

locals {
  schema_name = var.schema_name == null || var.schema_name == "" ? var.db_name : var.schema_name
}

resource "random_password" "user_admin" {
  length = 18
}

resource "postgresql_role" "db_admin" {
  name = "${var.db_name}_admin"
  login = false
}

resource "postgresql_database" "db" {
  name = var.db_name
  owner = postgresql_role.db_admin.name
  lc_ctype = "en_US.utf8"
  lc_collate = "en_US.utf8"
}

resource "postgresql_schema" "schema" {
  name = local.schema_name
  database = postgresql_database.db.name
  owner = postgresql_role.db_admin.name

  policy {
    create_with_grant = true
    usage_with_grant = true
    role = postgresql_role.db_user_admin_role.name
  }

  policy {
    usage = true
    role = postgresql_role.db_app.name
  }

  policy {
    usage = true
    role = postgresql_role.db_read.name
  }
}

resource "postgresql_role" "db_user_admin_role" {
  name = "${var.db_name}_user_admin_role"
  login = true
  password = random_password.user_admin.result
  create_role = true
}

resource "postgresql_role" "db_read" {
  name = "${var.db_name}_read_role"
  login = false
}

resource "postgresql_role" "db_app" {
  name = "${var.db_name}_app_role"
  login = false
}

resource "postgresql_default_privileges" "app" {
  database = postgresql_database.db.name
  schema = postgresql_schema.schema.name
  owner = postgresql_role.db_admin.name
  role = postgresql_role.db_app.name
  object_type = "table"
  privileges = ["ALL"]
}

resource "postgresql_default_privileges" "read" {
  database = postgresql_database.db.name
  schema = postgresql_schema.schema.name
  owner = postgresql_role.db_admin.name
  role = postgresql_role.db_read.name
  object_type = "table"
  privileges = ["SELECT"]
}