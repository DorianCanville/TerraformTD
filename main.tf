terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.48.0"
    }
  }
  backend "azurerm" {
    
  }
}

provider "azurerm" {
  # Configuration options
  features {  
  }
}

# resource "azurerm_resource_group" "rg" {
#   name     = "rg-dnce${var.environment_suffix}"
#   location = var.location
# }

######## expose port 80

resource "azurerm_service_plan" "app_plan" {
  name                = "app-plan-${var.project_name}${var.environment_suffix}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "web_app" {
  name                = "web-app-${var.project_name}${var.environment_suffix}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.app_plan.id

  #### tou pt
  # site_config {
  #   node_version     = "14-lts"
  #   scm_type         = "LocalGit"
  # }

  # app_settings =  {
  #       "PORT" = var.api_port
  #       "DB_HOST" = azurerm_postgresql_server.postgresql-server.fqdn
  #       "DB_USERNAME" = "${data.azurerm_key_vault_secret.postgres-login.value}@${azurerm_postgresql_server.postgresql-server.name}"
  #       "DB_PASSWORD" = data.azurerm_key_vault_secret.postgres-password.value
  #       "DB_DATABASE" = var.database_name
  #       "DB_DIALECT" = var.database_dialect
  #       "DB_PORT" = var.database_port
  #       "ACCESS_TOKEN_SECRET" = data.azurerm_key_vault_secret.access-token-secret.value
  #       "REFRESH_TOKEN_SECRET" = data.azurerm_key_vault_secret.refresh-token-secret.value
  #       "ACCESS_TOKEN_EXPIRY" = var.access_token_expiry
  #       "REFRESH_TOKEN_EXPIRY" = var.refresh_token_expiry
  #       "REFRESH_TOKEN_COOKIE_NAME" = var.refresh_token_cookie_name
  #   }
}


####### POSTGRESQL #######

resource "azurerm_postgresql_server" "postgresql-server" {
  name                = "postgresql-server-${var.project_name}${var.environment_suffix}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  sku_name = "B_Gen5_2"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = data.azurerm_key_vault_secret.postgres-login.value
  administrator_login_password = data.azurerm_key_vault_secret.postgres-password.value
  version                      = "9.5"
  ssl_enforcement_enabled      = false
  ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"
}

## pour être sur que l'appli à accès
resource "azurerm_postgresql_firewall_rule" "sql-srv" {
  name = "FirewallRule1"
  resource_group_name = data.azurerm_resource_group.rg.name
  server_name = azurerm_postgresql_server.postgresql-server.name
  start_ip_address = "0.0.0.0"
  end_ip_address = "0.0.0.0"
}

####### api #######


resource "azurerm_container_group" "api-nodejs" {
  name                = "aci-api-${var.project_name}${var.environment_suffix}"
  resource_group_name          = data.azurerm_resource_group.rg.name
  location                     = data.azurerm_resource_group.rg.location
  ip_address_type     = "Public"
  dns_name_label      = "aci-api-${var.project_name}${var.environment_suffix}"
  os_type             = "Linux"

  container {
    name   = "api-node"
    image  = "doriancanville/nodejs-exemple:1.0"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 3000
      protocol = "TCP"
    }


    environment_variables = {
        "PORT" = var.api_port
        "DB_HOST" = azurerm_postgresql_server.postgresql-server.fqdn
        "DB_USERNAME" = "${data.azurerm_key_vault_secret.postgres-login.value}@${azurerm_postgresql_server.postgresql-server.name}"
        "DB_PASSWORD" = data.azurerm_key_vault_secret.postgres-password.value
        "DB_DATABASE" = var.database_name
        "DB_DIALECT" = var.database_dialect
        "DB_PORT" = var.database_port
        "ACCESS_TOKEN_SECRET" = data.azurerm_key_vault_secret.access-token-secret.value
        "REFRESH_TOKEN_SECRET" = data.azurerm_key_vault_secret.refresh-token-secret.value
        "ACCESS_TOKEN_EXPIRY" = var.access_token_expiry
        "REFRESH_TOKEN_EXPIRY" = var.refresh_token_expiry
        "REFRESH_TOKEN_COOKIE_NAME" = var.refresh_token_cookie_name
    }
  }
}

####### pgadmin #######

resource "azurerm_container_group" "pgadmin" {
  name                = "aci-pgadmin-${var.project_name}${var.environment_suffix}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  ip_address_type     = "Public"
  dns_name_label      = "aci-pgadmin-${var.project_name}${var.environment_suffix}"
  os_type             = "Linux"

  container {
    name   = "pgadmin"
    image  = "dpage/pgadmin4:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }


    environment_variables = {
      "PGADMIN_DEFAULT_EMAIL" = data.azurerm_key_vault_secret.pgadmin-email.value
      "PGADMIN_DEFAULT_PASSWORD" = data.azurerm_key_vault_secret.pgadmin-password.value
    }
  }
}


# resource "azurerm_linux_web_app" "web_app" {
#   name                = "web-api-${var.project_name}${var.environment_suffix}"
#   location            = data.azurerm_resource_group.rg.location
#   resource_group_name = data.azurerm_resource_group.rg.name
#   service_plan_id = azurerm_service_plan.app-plan.id

#   site_config {
#     # application_stack {
#     #   dotnet_version = "6.0"
#     # }
#   }

#     connection_string {
#       # name = "DefaultConnection"
#       # value = "Server=tcp:${azurerm_mssql_server.sqlsrv.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.sqldb.name};Persist Security Info=False;User ID=${data.azurerm_key_vault_secret.dblogin.value};Password=${data.azurerm_key_vault_secret.dbpassword.value};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"  
#       # type = "SQLAzure"
#     }

#     app_settings = {
#       # "RabbitMQ__Hostname" = azurerm_container_group.rabbitmq.fqdn,
#       # "RabbitMQ__Username" = data.azurerm_key_vault_secret.rabbitmq-login.value,
#       # "RabbitMQ__Password" = data.azurerm_key_vault_secret.rabbitmq-password.value
#     }
# }

# resource "azurerm_service_plan" "app-plan" {
#   name                = "plan-${var.project_name}${var.environment_suffix}"
#   location            = data.azurerm_resource_group.rg.location
#   resource_group_name = data.azurerm_resource_group.rg.name
#   os_type             = "Linux"
#   sku_name            = "S1"
# }


####### END ########


# resource "azurerm_mssql_server" "sqlsrv" {
#   name                         = "sqlsrv-${var.project_name}${var.environment_suffix}"
#   resource_group_name          = data.azurerm_resource_group.rg.name
#   location                     = data.azurerm_resource_group.rg.location
#   version                      = "12.0"
#   administrator_login          = data.azurerm_key_vault_secret.dblogin.value
#   administrator_login_password = data.azurerm_key_vault_secret.dbpassword.value#/JeSaisPasQuoiMettre/76360
# }

# resource "azurerm_mssql_database" "sqldb" {
#   name           = "RabbitMqDemo"
#   server_id      = azurerm_mssql_server.sqlsrv.id
#   collation      = "SQL_Latin1_General_CP1_CI_AS"
#   license_type   = "LicenseIncluded"
#   //max_size_gb    = 2
#   read_scale     = false
#   sku_name       = "S0"
#   zone_redundant = false
# }

# resource "azurerm_mssql_firewall_rule" "sql-srv" {
#   name = "FirewallRule1"
#   server_id = azurerm_mssql_server.sqlsrv.id
#   start_ip_address = "0.0.0.0"
#   end_ip_address = "0.0.0.0"
# }


# resource "azurerm_container_group" "rabbitmq" {
#   name                = "aci-mq-${var.project_name}${var.environment_suffix}"
#   resource_group_name          = data.azurerm_resource_group.rg.name
#   location                     = data.azurerm_resource_group.rg.location
#   ip_address_type     = "Public"
#   dns_name_label      = "aci-mq-${var.project_name}${var.environment_suffix}"
#   os_type             = "Linux"

#   container {
#     name   = "rabbitmq"
#     image  = "rabbitmq:3-management"
#     cpu    = "0.5"
#     memory = "1.5"

#     ports {
#       port     = 5672
#       protocol = "TCP"
#     }

#     ports {
#       port     = 15672
#       protocol = "TCP"
#     }

#     environment_variables = {
#       "RABBITMQ_DEFAULT_USER" = data.azurerm_key_vault_secret.rabbitmq-login.value
#       "RABBITMQ_DEFAULT_PASS" = data.azurerm_key_vault_secret.rabbitmq-password.value
#     }
#   }
# }