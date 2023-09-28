terraform {
  backend "azurerm" {
    resource_group_name = "covtracker"
    storage_account_name = "covtrackertfstatestorage"
    container_name = "tfstate"
    key = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "covtracker" {
  name = "covtracker"
  location = "West Europe"
}

resource "azurerm_mysql_server" "mysqlserver" {
  name                = "marushov-mysqlserver"
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login          = "__db_login__"
  administrator_login_password = "__db_password__"

  sku_name   = "B_Gen5_1"
  storage_mb = 51200
  version    = "5.7"

  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
}

resource "azurerm_mysql_database" "mysqldb" {
  name                = "marushov-mysqldb"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.mysqlserver.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "marushov-k8s"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "aks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_A2m_v2"
  }

  identity {
    type = "SystemAssigned"
  }

}

resource "azurerm_container_registry" "acr" {
  name                = "marushovAcr"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
}