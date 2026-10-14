terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "1-e11996eb-playground-sandbox"
    storage_account_name = "tfstatepacificoxyz" # <--- Nombre corto correcto de 17 caracteres
    container_name       = "tfstate"
    key                  = "pacifico-prod.tfstate"
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}