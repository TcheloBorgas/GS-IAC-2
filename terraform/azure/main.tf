resource "azurerm_resource_group" "rg-staticsite" {
  name     = "poneis5"
  location = "eastus"
}
 
resource "azurerm_storage_account" "stracctstaticsite" {
  name                     = var.stracctstaticsite
  resource_group_name      = azurerm_resource_group.rg-staticsite.name
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  static_website {
    index_document     = "index.html"
    error_404_document = "error.html"
  }
}
 
resource "azurerm_storage_blob" "index" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.stracctstaticsite.name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = "text/html"
  source                 = "app/index.html"
}

resource "azurerm_storage_blob" "error" {
  name                   = "error.html"
  storage_account_name   = azurerm_storage_account.stracctstaticsite.name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = "text/html"
  source                 = "app/error.html"
}

# ---------------------------------------------

# recurso de ip
resource "azurerm_public_ip" "lb-pip" {
  name                = "loadbalancer-public-ip"
  location            = azurerm_resource_group.rg-staticsite.location
  resource_group_name = azurerm_resource_group.rg-staticsite.name
  allocation_method   = "Static"
  sku                 = "Basic"
}

# recurso load balancer

resource "azurerm_lb" "lb" {
  name                = "loadbalancer"
  location            = azurerm_resource_group.rg-staticsite.location
  resource_group_name = azurerm_resource_group.rg-staticsite.name

  frontend_ip_configuration {
    name                 = "public-ip-config"
    public_ip_address_id = azurerm_public_ip.lb-pip.id
  }
}

# regras de trafego

resource "azurerm_lb_rule" "lb-rule-http" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "public-ip-config"
  enable_floating_ip             = false
  idle_timeout_in_minutes        = 4
  load_distribution              = "Default"
}
