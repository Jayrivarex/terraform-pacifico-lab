# Referencia al Resource Group existente en el Sandbox
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# 1. App Service Plan en SKU S1 (Standard)
resource "azurerm_service_plan" "asp" {
  name                = "asp-pacifico-devops"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "S1"
}

# 2. Azure App Service (Web App) con Identidad Administrada System-Assigned
resource "azurerm_linux_web_app" "app" {
  name                = "app-pacifico-api-xyz"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.asp.id
  https_only          = true # Mantenemos la seguridad HTTPS obligatoria

  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
    always_on = true
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }
}

# 3. Servidor Lógico de Base de Datos Azure SQL (Con Lifecycle ignore_changes)
resource "azurerm_mssql_server" "sql_server" {
  name                         = "sqladmin-devops"
  resource_group_name          = data.azurerm_resource_group.rg.name
  location                     = data.azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password

  # Ignoramos cambios en la contraseña para evitar bloqueos en recursos importados
  lifecycle {
    ignore_changes = [
      administrator_login_password,
    ]
  }
}

# 4. Base de Datos Transaccional Azure SQL
resource "azurerm_mssql_database" "db" {
  name        = "db-pacifico-core"
  server_id   = azurerm_mssql_server.sql_server.id
  sku_name    = "Basic"
  max_size_gb = 2
}

# 5. Regla de Firewall para permitir acceso desde servicios de Azure
resource "azurerm_mssql_firewall_rule" "allow_azure" {
  name             = "AllowAllWindowsAzureIps"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}