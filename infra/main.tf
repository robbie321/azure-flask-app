# infra/main.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "flask-app-rg"
    storage_account_name = "tfstaterobbie321"
    container_name       = "tfstate"
    key                  = "flask-app.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "flask-app-rg"
  location = "West Europe"
}

resource "azurerm_service_plan" "plan" {
  name                = "flask-app-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "app" {
  name                = "flask-app-robbie321"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    always_on = false
    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = {
    "DB_HOST" = azurerm_postgresql_flexible_server.db.fqdn
    "DB_NAME" = "flaskappdb"
    "DB_USER" = "flaskadmin"
    "DB_PASS" = var.db_password
  }
}

resource "azurerm_postgresql_flexible_server" "db" {
  name                   = "flask-db-robbie321"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = "16"
  administrator_login    = "flaskadmin"
  administrator_password = var.db_password
  storage_mb             = 32768
  sku_name               = "B_Standard_B1ms"
  backup_retention_days  = 7
  zone                   = "1"
}

resource "azurerm_postgresql_flexible_server_database" "appdb" {
  name      = "flaskappdb"
  server_id = azurerm_postgresql_flexible_server.db.id
  collation = "en_US.utf8"
  charset   = "utf8"
}