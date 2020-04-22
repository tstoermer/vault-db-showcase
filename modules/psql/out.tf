output "db_user_admin_name" {
  value = postgresql_role.db_user_admin_role.name
}

output "db_user_admin_password" {
  value = random_password.user_admin.result
  sensitive = true
}

output "db_name" {
  value = postgresql_database.db.name
}

output "db_read_role" {
  value = postgresql_role.db_read.name
}

output "db_app_role" {
  value = postgresql_role.db_app.name
}

output "db_admin_role" {
  value = postgresql_role.db_admin.name
}