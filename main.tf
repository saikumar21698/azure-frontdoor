resource "azurerm_resource_group" "staicweb" {
  name     = "staticweb"
  location = "uksouth"
}

resource "azurerm_storage_account" "staticwebsa" {
  name                     = "staticwebstorage"
  resource_group_name      = azurerm_resource_group.staticweb.name
  location                 = azurerm_resource_group.staticweb.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}
resource "azurerm_dns_zone" "staticdns" {
  name                = "lloyd.com"
  resource_group_name = azurerm_resource_group.staticweb.name
}

resource "azurerm_dns_cname_record" "example" {
  name                = "test"
  zone_name           = azurerm_dns_zone.staticdns.name
  resource_group_name = azurerm_resource_group.staticweb.name
  ttl                 = 300
  record              = "dev-FrontDoor.azurefd.net"
}
data "azurerm_key_vault" "vault" {
  name                = "example-vault"
  resource_group_name = "example-vault-rg"
}

resource "azurerm_frontdoor" "static" {
  name                = "static-FrontDoor"
  resource_group_name = azurerm_resource_group.staticweb.name

  routing_rule {
    name               = "exampleRoutingRule1"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["exampleFrontendEndpoint1"]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "exampleBackendBing"
    }
  }

  backend_pool_load_balancing {
    name = "exampleLoadBalancingSettings1"
  }

  backend_pool_health_probe {
    name = "exampleHealthProbeSetting1"
  }

  backend_pool {
    name = "exampleBackendBing"
    backend {
      host_header = "appservice.azurewebsites.net"
      address     = "appservice.azurewebsites.net"
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "exampleLoadBalancingSettings1"
    health_probe_name   = "exampleHealthProbeSetting1"
  }

  frontend_endpoint {
    name      = "exampleFrontendEndpoint1"
    host_name = "dev-FrontDoor.azurefd.net"
  }

  frontend_endpoint {
    name      = "exampleFrontendEndpoint2"
    host_name = "dev.lloyd.com"
  }
}

resource "azurerm_frontdoor_custom_https_configuration" "example_custom_https_0" {
  frontend_endpoint_id              = azurerm_frontdoor.static.frontend_endpoints["exampleFrontendEndpoint1"]
  custom_https_provisioning_enabled = false
}

resource "azurerm_frontdoor_custom_https_configuration" "example_custom_https_1" {
  frontend_endpoint_id              = azurerm_frontdoor.static.frontend_endpoints["exampleFrontendEndpoint2"]
  custom_https_provisioning_enabled = true

  custom_https_configuration {
    certificate_source                      = "AzureKeyVault"
    azure_key_vault_certificate_secret_name = "examplefd1"
    azure_key_vault_certificate_vault_id    = data.azurerm_key_vault.vault.id
  }
}
