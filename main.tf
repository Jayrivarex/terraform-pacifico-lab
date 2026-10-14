# Referencia al Resource Group existente en el Sandbox
data "azurerm_resource_group" "rg" {
  name = "1-e11996eb-playground-sandbox"
}

# ==========================================
# 1. CAPA DE CÓMPUTO PAAS (App Service)
# ==========================================
resource "azurerm_service_plan" "asp" {
  name                = "asp-pacifico-devops"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "app" {
  name                = "app-pacifico-api-xyz"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.asp.id
  https_only          = true

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

# ==========================================
# 2. CAPA DE CONTENEDORES Y ORQUESTACIÓN (ACR & AKS)
# ==========================================

resource "azurerm_container_registry" "acr" {
  name                = "acrpacificodevopsxyz"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-pacifico-cluster"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = "akspacificodns"
  oidc_issuer_enabled = true

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
    Client      = "Banco Pacifico"
  }
}

# ==========================================
# 3. CAPA DE DATOS (Azure SQL & Firewall)
# ==========================================
resource "azurerm_mssql_server" "sql_server" {
  name                         = "sqladmin-devops-xyz"
  resource_group_name          = data.azurerm_resource_group.rg.name
  location                     = data.azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "CloudSA4c4bbdf1"
  administrator_login_password = "*ypfm$59"

  lifecycle {
    ignore_changes = [
      administrator_login,
      administrator_login_password,
    ]
  }
}

resource "azurerm_mssql_database" "db" {
  name        = "db-pacifico-core"
  server_id   = azurerm_mssql_server.sql_server.id
  sku_name    = "Basic"
  max_size_gb = 2

  lifecycle {
    ignore_changes = [
      storage_account_type,
    ]
  }
}

resource "azurerm_mssql_firewall_rule" "allow_azure" {
  name             = "AllowAllWindowsAzureIps"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}