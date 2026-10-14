output "app_service_url" {
  value       = "https://${azurerm_linux_web_app.app.default_hostname}"
  description = "URL publica asignada al App Service de produccion"
}

output "sql_server_fqdn" {
  value       = azurerm_mssql_server.sql_server.fully_qualified_domain_name
  description = "FQDN completo del servidor Azure SQL"
}