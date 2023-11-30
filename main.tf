resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "myappservice-plan"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "app_service" {
  name                = "mywebapp-453627 "
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
}
resource "azurerm_frontdoor" "votingdemofd" {
  name                                         = digitalsign
  resource_group_name                          = azurerm_resource_group.rg.name
  enforce_backend_pools_certificate_name_check = false

  routing_rule {
    name               = "digitalsignRoutingRule1"
    accepted_protocols = ["Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = [digitalsign]
    forwarding_configuration {
      forwarding_protocol = "HttpsOnly"
      backend_pool_name   = "digitalsignBackend"
      cache_enabled = true
      cache_query_parameter_strip_directive = "StripNone"
      cache_use_dynamic_compression         = true  
    }

  }

  backend_pool_load_balancing {
    name = "digitalsignLoadBalancingSettings1"

  }

  backend_pool_health_probe {
    name = "digitalsignHealthProbeSetting1"
    protocol              = "Https"
  }

  backend_pool {
    name = "votingDemoBackend"
    backend {
      host_header = "${var.app_svc_name}.azurewebsites.net" 
      address = "${var.app_svc_name}.azurewebsites.net" 
      http_port   =  80
      https_port  =  443
    }

    load_balancing_name = "votingDemoLoadBalancingSettings1"
    health_probe_name   = "votingDemoHealthProbeSetting1"
  }

  frontend_endpoint {
    name                              = var.front_end_point //bug 4495 "votingdemofd"
    host_name                         = "${var.front_end_point}.azurefd.net"
    session_affinity_enabled          = false 
    session_affinity_ttl_seconds      = 0     
    custom_https_provisioning_enabled = false
  }
}



