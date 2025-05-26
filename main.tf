
resource "azurerm_application_gateway" "appgw" {
  name                = var.appgw_name #"example-appgw"
  resource_group_name = azurerm_resource_group.rg_app.name
  location            = azurerm_resource_group.rg_app.location

  identity { # done
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.identity.id]
  }

  sku { #done
    name     = var.appgw_sku_name
    tier     = var.appgw_sku_tier
    capacity = var.appgw_sku_capacity
  }

  dynamic "gateway_ip_configuration" {      #done
    for_each = var.gateway_ip_configuration #required
    content {
      name      = gateway_ip_configuration.value.name
      subnet_id = azurerm_subnet.snet_app.id
    }
  }

  dynamic "frontend_port" { #done
    for_each = var.frontend_port
    content {
      name = frontend_port.value.name
      port = frontend_port.value.port
    }
  }

  dynamic "frontend_ip_configuration" { #done
    for_each = var.frontend_ip_configuration
    content {
      name                            = frontend_ip_configuration.value.name
      subnet_id                       = frontend_ip_configuration.value.public_ip_enabled ? null : azurerm_subnet.snet_app.id
      private_ip_address              = frontend_ip_configuration.value.public_ip_enabled ? null : frontend_ip_configuration.value.private_ip_address
      public_ip_address_id            = frontend_ip_configuration.value.public_ip_enabled ? azurerm_public_ip.pip_appgw.id : null
      private_ip_address_allocation   = frontend_ip_configuration.value.public_ip_enabled ? null : "Static"
      private_link_configuration_name = lookup(frontend_ip_configuration.value, "private_link_configuration_name", null)
    }
  }

  dynamic "backend_address_pool" {      #done
    for_each = var.backend_address_pool #required
    content {
      name         = backend_address_pool.value.name
      ip_addresses = backend_address_pool.value.ip_addresses
    }
  }

  dynamic "backend_http_settings" {      #done
    for_each = var.backend_http_settings #required
    content {
      name                                = backend_http_settings.value.name
      protocol                            = backend_http_settings.value.protocol
      port                                = backend_http_settings.value.port
      request_timeout                     = backend_http_settings.value.request_timeout
      cookie_based_affinity               = backend_http_settings.value.cookie_based_affinity
      path                                = backend_http_settings.value.path
      affinity_cookie_name                = lookup(backend_http_settings.value, "affinity_cookie_name", null)
      probe_name                          = lookup(backend_http_settings.value, "probe_name", null)
      host_name                           = lookup(backend_http_settings.value, "host_name", null)
      pick_host_name_from_backend_address = lookup(backend_http_settings.value, "pick_host_name_from_backend_address", null)
    }
  }

  dynamic "http_listener" { #done
    for_each = var.http_listener
    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = http_listener.value.frontend_ip_configuration_name
      frontend_port_name             = http_listener.value.frontend_port_name
      protocol                       = http_listener.value.protocol
      ssl_certificate_name           = lookup(http_listener.value, "ssl_certificate_name", null)
      ssl_profile_name               = lookup(http_listener.value, "ssl_profile_name", null)
      firewall_policy_id             = lookup(http_listener.value, "firewall_policy_id", null)
      require_sni                    = lookup(http_listener.value, "require_sni", null)
      host_name                      = lookup(http_listener.value, "host_name", null)
      host_names                     = lookup(http_listener.value, "host_names", null)
    }
  }

  dynamic "request_routing_rule" {      #done
    for_each = var.request_routing_rule #required
    content {
      priority                    = request_routing_rule.value.priority
      name                        = request_routing_rule.value.name
      rule_type                   = request_routing_rule.value.rule_type
      http_listener_name          = request_routing_rule.value.http_listener_name
      backend_address_pool_name   = request_routing_rule.value.backend_address_pool_name
      backend_http_settings_name  = request_routing_rule.value.backend_http_settings_name
      redirect_configuration_name = lookup(request_routing_rule.value, "redirect_configuration_name", null)
      url_path_map_name           = lookup(request_routing_rule.value, "url_path_map_name", null)
      rewrite_rule_set_name       = lookup(request_routing_rule.value, "rewrite_rule_set_name", null)
      #(Optional) The Name of the Rewrite Rule Set which should be used for this Routing Rule. Only valid for v2 SKUs.
    }
  }

  dynamic "probe" { #done
    for_each = length(var.probes) > 0 ? var.probes : []
    content {
      name                = probe.value.name
      protocol            = probe.value.protocol
      path                = probe.value.path
      interval            = probe.value.interval
      timeout             = probe.value.timeout
      unhealthy_threshold = probe.value.unhealthy_threshold

      host                                      = lookup(probe.value, "host", null)
      port                                      = lookup(probe.value, "port", null)
      pick_host_name_from_backend_http_settings = lookup(probe.value, "pick_host_name_from_backend_http_settings", null)
      minimum_servers                           = lookup(probe.value, "minimum_servers", null)
      dynamic "match" {
        for_each = lookup(probe.value, "match", {})
        content {
          body        = match.value.body
          status_code = match.value.status_codes
        }
      }
    }
  }

  dynamic "url_path_map" { #done
    for_each = length(var.url_path_maps) > 0 ? var.url_path_maps : []
    content {
      name                                = url_path_map.value.name
      default_backend_address_pool_name   = url_path_map.value.default_backend_address_pool_name
      default_backend_http_settings_name  = url_path_map.value.default_backend_http_settings_name
      default_redirect_configuration_name = lookup(url_path_map.value, "default_redirect_configuration_name", null)
      default_rewrite_rule_set_name       = lookup(url_path_map.value, "default_rewrite_rule_set_name", null)

      dynamic "path_rule" {
        for_each = toset(url_path_map.value.path_rules)
        content {
          name                        = path_rule.value.name
          paths                       = path_rule.value.paths
          backend_address_pool_name   = path_rule.value.backend_address_pool_name
          backend_http_settings_name  = path_rule.value.backend_http_settings_name
          redirect_configuration_name = lookup(path_rule.value, "redirect_configuration_name", null)
        }
      }
    }
  }

  dynamic "autoscale_configuration" { #done
    for_each = var.enable_autoscale && var.autoscale_configuration != null ? [var.autoscale_configuration] : []
    content {
      max_capacity = autoscale_configuration.value.max_capacity
      min_capacity = autoscale_configuration.value.min_capacity
    }
  }

  dynamic "redirect_configuration" { #done
    for_each = length(var.redirect_configuration) > 0 ? var.redirect_configuration : []
    content {
      name                 = redirect_configuration.value.name
      redirect_type        = redirect_configuration.value.redirect_type
      target_listener_name = redirect_configuration.value.target_listener_name
      target_url           = redirect_configuration.value.target_url
      include_path         = redirect_configuration.value.include_path
      include_query_string = redirect_configuration.value.include_query_string
    }
  }

  dynamic "rewrite_rule_set" {
    for_each = length(var.rewrite_rule_set) > 0 ? var.rewrite_rule_set : []
    content {
      name = rewrite_rule_set.value.name
      dynamic "rewrite_rule" {
        for_each = toset(rewrite_rule_set.value.rewrite_rules)
        content {
          name          = rewrite_rule_set.value.name
          rule_sequence = rewrite_rule.value.rule_type
          dynamic "condition" {
            for_each = length(rewrite_rule.value.condition) > 0 ? rewrite_rule.value.condition : []
            content {
              variable    = condition.value.variable
              pattern     = condition.value.pattern
              ignore_case = lookup(condition.value, "ignore_case", false)
              negate      = lookup(condition.value, "negate", false)
            }
          }
          dynamic "request_header_configuration" {
            for_each = length(rewrite_rule.value.request_header_configuration) > 0 ? rewrite_rule.value.request_header_configuration : []
            content {
              header_name  = request_header_configuration.value.header_name
              header_value = request_header_configuration.value.header_value
            }
          }
          dynamic "response_header_configuration" {
            for_each = length(rewrite_rule.value.response_header_configuration) > 0 ? rewrite_rule.value.response_header_configuration : []
            content {
              header_name  = response_header_configuration.value.header_name
              header_value = response_header_configuration.value.header_value
            }
          }
          dynamic "url" {
            for_each = length(rewrite_rule.value.url) > 0 ? rewrite_rule.value.url : []
            content {
              path         = url.value.path
              query_string = url.value.query_string
              components   = lookup(url.value, "components", null)
              reroute      = lookup(url.value, "reroute", null)
            }
          }
        }
      }
    }
  }
  # dynamic "ssl_certificate" {
  #   for_each = lookup(each.value, "ssl_certificate", {})
  #   content {
  #     name                = ssl_certificate.value.name
  #     key_vault_secret_id = ssl_certificate.value.key_vault_secret_id
  #   }
  # }

  # dynamic "waf_configuration" {
  #   for_each = var.waf_configurations
  #   content {
  #     enabled          = waf_configuration.value.enabled
  #     firewall_mode    = waf_configuration.value.firewall_mode
  #     rule_set_type    = waf_configuration.value.rule_set_type # opcional
  #     rule_set_version = waf_configuration.value.rule_set_version

  #     file_upload_limit_mb     = try(waf_configuration.value.file_upload_limit_mb, null)     # opcional
  #     max_request_body_size_kb = try(waf_configuration.value.max_request_body_size_kb, null) # opcional
  #     request_body_check       = try(waf_configuration.value.request_body_check, null)       # opcional
  #   }
  # }
}
