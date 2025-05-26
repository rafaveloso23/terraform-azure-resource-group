#string
appgw_name         = "example-appgw"
appgw_sku_name     = "Standard_v2"
appgw_sku_tier     = "Standard_v2"
appgw_sku_capacity = 2


#mutiples configurations
frontend_ip_configuration = [
  {
    name              = "appgw-frontend-ip"
    public_ip_enabled = true
  }
]
frontend_port = [
  { name = "http-port", port = 80 }
]
gateway_ip_configuration = [
  { name = "appgw-gateway-ip-1" }
]
backend_address_pool = [
  { name = "backend-pool-1", ip_addresses = ["10.0.1.4", "10.0.1.5"] }
]
backend_http_settings = [
  {
    name                  = "backend-http-settings-1"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }
]
http_listener = [
  {
    name                           = "http-listener-1"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }
]
request_routing_rule = [
  {
    name                       = "rule-1"
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = "http-listener-1"
    backend_address_pool_name  = "backend-pool-1"
    backend_http_settings_name = "backend-http-settings-1"
  }
]
probes = [
  # {
  #   # name                = "probe1"
  #   # protocol            = "Http"
  #   # path                = "/health"
  #   # interval            = 30
  #   # timeout             = 30
  #   # unhealthy_threshold = 3

  #   # host                                     = "127.0.0.1"
  #   # port                                     = 8080
  #   # pick_host_name_from_backend_http_settings = false
  #   # minimum_servers                          = 1

  #   # match = [
  #   #   {
  #   #     body         = "Healthy"
  #   #     status_codes = ["200", "202"]
  #   #   }
  #   # ]
  # }
]
url_path_maps = [
  # {
  #   name                                = "map-with-backend"
  #   default_backend_address_pool_name   = "app-backend-pool"
  #   default_backend_http_settings_name  = "app-http-settings"
  #   # default_redirect_configuration_name is omitted
  #   path_rules = [
  #     {
  #       name                        = "rule-redirect"
  #       paths                       = ["/old-path/*"]
  #       backend_address_pool_name   = "app-backend-pool"
  #       backend_http_settings_name  = "app-http-settings"
  #       redirect_configuration_name = "redirect-config"
  #     }
  #   ]
  # }
]
redirect_configuration = [
  {
    name                 = "redirect-to-https"
    redirect_type        = "Permanent"      # ou "Found", "Temporary", "SeeOther"
    target_listener_name = "https-listener" # opcional se for usar target_url
    target_url           = null             # ou "https://example.com" se não usar listener
    include_path         = true
    include_query_string = true
  }
]
rewrite_rule_set = [
  {
    name = "my-rewrite-set"
    rewrite_rules = [
      {
        name      = "rewrite-rule-1"
        rule_type = 1

        conditions = [
          {
            variable    = "http_user_agent"
            pattern     = ".*Chrome.*"
            ignore_case = true
            negate      = false
          }
        ]

        request_header_configuration = [
          {
            header_name  = "x-custom-header"
            header_value = "custom-value"
          }
        ]

        response_header_configuration = [
          {
            header_name  = "x-powered-by"
            header_value = "Terraform"
          }
        ]

        url = [
          {
            path         = "/new-path"
            query_string = "id=123"
            components   = "query_string_only"
            reroute      = true
          }
        ]
      }
    ]
  }
]
