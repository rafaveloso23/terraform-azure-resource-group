variable "appgw_name" {
  type = string
}

variable "appgw_sku_name" {
  description = "SKU Name for Application Gateway"
  type        = string
  default     = "Standard_v2"
}

variable "appgw_sku_tier" {
  description = "SKU Tier for Application Gateway"
  type        = string
  default     = "Standard_v2"
}

variable "appgw_sku_capacity" {
  description = "Capacity for Application Gateway"
  type        = number
  default     = 2
}

variable "frontend_ip_configuration" {
  description = "Frontend IP Configuration list"
  type = list(object({
    name                            = string
    public_ip_enabled               = bool
    private_ip_address              = optional(string)
    private_link_configuration_name = optional(string)
  }))
}

variable "frontend_port" {
  type = list(object({
    name = string
    port = number
  }))
}

variable "backend_address_pool" {
  type = list(object({
    name         = string
    ip_addresses = list(string)
  }))
}

variable "backend_http_settings" {
  type = list(object({
    name                                = string
    cookie_based_affinity               = optional(string, "Disabled")
    affinity_cookie_name                = optional(string, null)
    path                                = optional(string, null)
    port                                = number
    probe_name                          = optional(string, null)
    protocol                            = string
    request_timeout                     = number
    host_name                           = optional(string, null)
    pick_host_name_from_backend_address = optional(string, null)
  }))
}

variable "gateway_ip_configuration" {
  type = list(object({
    name = string
  }))
}

variable "http_listener" {
  type = list(object({
    name                           = string
    frontend_ip_configuration_name = string
    frontend_port_name             = string
    protocol                       = string
    ssl_certificate_name           = optional(string, null)
    host_name                      = optional(string, null)
    host_names                     = optional(list(string), null)
    require_sni                    = optional(bool, null)
    firewall_policy_id             = optional(string, null)
    ssl_profile_name               = optional(string, null)
  }))
}

variable "request_routing_rule" {
  type = list(object({
    name                        = string
    priority                    = number
    rule_type                   = string
    http_listener_name          = string
    backend_address_pool_name   = string
    backend_http_settings_name  = string
    redirect_configuration_name = optional(string, null)
    url_path_map_name           = optional(string, null)
    rewrite_rule_set_name       = optional(string, null)
  }))
}

variable "probes" {
  type = list(object({
    name                                      = string
    protocol                                  = string
    path                                      = string
    interval                                  = number
    timeout                                   = number
    unhealthy_threshold                       = number
    host                                      = optional(string)
    port                                      = optional(number)
    pick_host_name_from_backend_http_settings = optional(bool)
    minimum_servers                           = optional(number)
    match = optional(list(object({
      body         = optional(string)
      status_codes = list(string)
    })))
  }))
}

variable "url_path_maps" {
  type = list(object({
    name                                = string
    default_backend_address_pool_name   = optional(string)
    default_backend_http_settings_name  = optional(string)
    default_redirect_configuration_name = optional(string)
    default_rewrite_rule_set_name       = optional(string)
    path_rules = list(object({
      name                        = string
      paths                       = list(string)
      backend_address_pool_name   = string
      backend_http_settings_name  = string
      redirect_configuration_name = optional(string)
    }))
  }))
}

variable "enable_autoscale" {
  type    = bool
  default = false
}

variable "autoscale_configuration" {
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default = null
}

variable "redirect_configuration" {
  type = list(object({
    name                 = string
    redirect_type        = string
    target_url           = optional(string, null)
    include_path         = optional(bool, true)
    include_query_string = optional(bool, true)
    target_listener_name = optional(string, null)
  }))
}

variable "rewrite_rule_set" {
  type = list(object({
    name = string
    rewrite_rules = list(object({
      name          = string
      rule_type     = number
      condition = optional(list(object({
        variable    = string
        pattern     = string
        ignore_case = optional(bool)
        negate      = optional(bool)
      })), [])
      request_header_configuration = optional(list(object({
        header_name  = string
        header_value = string
      })), [])
      response_header_configuration = optional(list(object({
        header_name  = string
        header_value = string
      })), [])
      url = optional(list(object({
        path         = string
        query_string = string
        components   = optional(string)
        reroute      = optional(bool)
      })), [])
    }))
  }))
  default = []
}

