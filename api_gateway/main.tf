resource "aws_api_gateway_rest_api" "api" {
  name = "${var.name}-${var.environment}-api"
   endpoint_configuration {
    types = ["REGIONAL"]
  }
}
/*resource "aws_api_gateway_resource" "java" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part = "java"
}

resource "aws_api_gateway_resource" "java_proxy" {
  rest_api_id ="${aws_api_gateway_rest_api.api.id}"
  parent_id = "${aws_api_gateway_resource.java.id}"
  path_part = "{proxy+}"
}
resource "aws_api_gateway_method" "java_proxy" {
  authorization = "NONE"
  http_method   = "ANY"
  resource_id   = aws_api_gateway_resource.java_proxy.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method_response" "java_proxy_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.java_proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = "200"
}
resource "aws_api_gateway_integration_response" "java_proxy_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.java_proxy.id
  http_method = aws_api_gateway_method.java_proxy.http_method
  status_code = aws_api_gateway_method_response.java_proxy_response_200.status_code
}

resource "aws_api_gateway_method" "java_proxy_options" {
  authorization = "NONE"
  http_method   = "OPTIONS"
  resource_id   = aws_api_gateway_resource.java_proxy.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
}
resource "aws_api_gateway_integration" "java_proxy_options" {
  http_method = aws_api_gateway_method.java_proxy_options.http_method
  resource_id = aws_api_gateway_resource.java_proxy.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  type        = "MOCK"
}
resource "aws_api_gateway_method_response" "java_proxy_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.java_proxy.id
  http_method = aws_api_gateway_method.java_proxy_options.http_method
  status_code = "200"
}
resource "aws_api_gateway_integration_response" "java_proxy_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.java_proxy.id
  http_method = aws_api_gateway_method.java_proxy_options.http_method
  status_code = aws_api_gateway_method_response.java_proxy_options_response_200.status_code
}*/

#####################################################
resource "aws_api_gateway_resource" "node" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part = "node"
}
#####################################################
resource "aws_api_gateway_resource" "auth" {
  rest_api_id ="${aws_api_gateway_rest_api.api.id}"
  parent_id = "${aws_api_gateway_resource.node.id}"
  path_part = "auth"
}
####################################################
resource "aws_api_gateway_resource" "get_otp" {
  rest_api_id ="${aws_api_gateway_rest_api.api.id}"
  parent_id = "${aws_api_gateway_resource.auth.id}"
  path_part = "get_otp"
}

resource "aws_api_gateway_method" "get_otp_options" {
  authorization = "NONE"
  http_method   = "OPTIONS"
  resource_id   = aws_api_gateway_resource.get_otp.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
}
resource "aws_api_gateway_integration" "get_otp_options" {
  http_method = aws_api_gateway_method.get_otp_options.http_method
  resource_id = aws_api_gateway_resource.get_otp.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  type        = "MOCK"
}
resource "aws_api_gateway_method_response" "get_otp_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.get_otp.id
  http_method = aws_api_gateway_method.get_otp_options.http_method
  status_code = "200"
}
resource "aws_api_gateway_integration_response" "get_otp_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.get_otp.id
  http_method = aws_api_gateway_method.get_otp_options.http_method
  status_code = aws_api_gateway_method_response.get_otp_options_response_200.status_code
}
resource "aws_api_gateway_deployment" "get_api_options" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers = {
    redeployment = sha1(jsonencode([aws_api_gateway_resource.get_otp.id,
      aws_api_gateway_method.get_otp_options.id,
      aws_api_gateway_integration.get_otp_options.id,
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_api_gateway_method" "get_otp_post" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.get_otp.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
}
resource "aws_api_gateway_integration" "get_otp_post" {
  http_method = aws_api_gateway_method.get_otp_post.http_method
  resource_id = aws_api_gateway_resource.get_otp.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  type        = "HTTP_PROXY"
  integration_http_method  = "POST"
  uri = "http://api.endpoint.com/proxy"
  passthrough_behavior     = "WHEN_NO_MATCH"
}
resource "aws_api_gateway_method_response" "get_otp_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.get_otp.id
  http_method = aws_api_gateway_method.get_otp_post.http_method
  status_code = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
  response_models = { "application/json" = "Empty"}
}
resource "aws_api_gateway_integration_response" "get_otp_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.get_otp.id
  http_method = aws_api_gateway_method.get_otp_post.http_method
  status_code = aws_api_gateway_method_response.get_otp_post_response_200.status_code
  response_templates = {
    "application/json" = <<EOF
    #set($inputRoot = $input.path('$'))
    <?xml version="1.0" encoding="UTF-8"?>
    <message>
    $inputRoot.body
    </message>
    EOF
    }
  }
resource "aws_api_gateway_deployment" "get_otp_post" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers = {
    redeployment = sha1(jsonencode([aws_api_gateway_resource.get_otp.id,
      aws_api_gateway_method.get_otp_post.id,
      aws_api_gateway_integration.get_otp_post.id,
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}


#####################################################
resource "aws_api_gateway_resource" "register" {
  rest_api_id ="${aws_api_gateway_rest_api.api.id}"
  parent_id = "${aws_api_gateway_resource.auth.id}"
  path_part = "register"
}

resource "aws_api_gateway_method" "register_options" {
  authorization = "NONE"
  http_method   = "OPTIONS"
  resource_id   = aws_api_gateway_resource.register.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_integration" "register_options" {
  http_method = aws_api_gateway_method.register_options.http_method
  resource_id = aws_api_gateway_resource.register.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  type        = "MOCK"
}
resource "aws_api_gateway_method_response" "register_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.register.id
  http_method = aws_api_gateway_method.register_options.http_method
  status_code = "200"
  response_models = { "application/json" = "Empty"}

}
resource "aws_api_gateway_integration_response" "register_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.register.id
  http_method = aws_api_gateway_method.register_options.http_method
  status_code = aws_api_gateway_method_response.register_options_response_200.status_code
}

resource "aws_api_gateway_method" "register_post" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.register.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
}
resource "aws_api_gateway_integration" "register_post" {
  http_method = aws_api_gateway_method.register_post.http_method
  resource_id = aws_api_gateway_resource.register.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  type        = "HTTP_PROXY"
  integration_http_method  = "POST"
  uri = "http://api.endpoint.com/proxy"
  passthrough_behavior     = "WHEN_NO_MATCH"
}
resource "aws_api_gateway_method_response" "register_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.register.id
  http_method = aws_api_gateway_method.register_post.http_method
  status_code = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
  response_models = { "application/json" = "Empty"}
}
resource "aws_api_gateway_integration_response" "register_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.register.id
  http_method = aws_api_gateway_method.register_post.http_method
  status_code = aws_api_gateway_method_response.register_post_response_200.status_code
    response_templates = {
    "application/json" = <<EOF
    #set($inputRoot = $input.path('$'))
    <?xml version="1.0" encoding="UTF-8"?>
    <message>
    $inputRoot.body
    </message>
    EOF
    }
}
  
resource "aws_api_gateway_deployment" "register_post" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers = {
    redeployment = sha1(jsonencode([aws_api_gateway_resource.register.id,
      aws_api_gateway_method.register_post.id,
      aws_api_gateway_integration.register_post.id,
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}
#####################################################

resource "aws_api_gateway_resource" "verify_otp" {
  rest_api_id ="${aws_api_gateway_rest_api.api.id}"
  parent_id = "${aws_api_gateway_resource.auth.id}"
  path_part = "verify_otp"
}

resource "aws_api_gateway_method" "verify_otp_options" {
  authorization = "NONE"
  http_method   = "OPTIONS"
  resource_id   = aws_api_gateway_resource.verify_otp.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
}
resource "aws_api_gateway_integration" "verify_otp_options" {
  http_method = aws_api_gateway_method.verify_otp_options.http_method
  resource_id = aws_api_gateway_resource.verify_otp.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  type        = "MOCK"
}

resource "aws_api_gateway_method_response" "verify_otp_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.verify_otp.id
  http_method = aws_api_gateway_method.verify_otp_options.http_method
  status_code = "200"
  response_models = { "application/json" = "Empty"}

}
resource "aws_api_gateway_integration_response" "verify_otp_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.verify_otp.id
  http_method = aws_api_gateway_method.verify_otp_options.http_method
  status_code = aws_api_gateway_method_response.verify_otp_options_response_200.status_code
}

resource "aws_api_gateway_deployment" "verify_otp_options" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers = {
    redeployment = sha1(jsonencode([aws_api_gateway_resource.verify_otp.id,
      aws_api_gateway_method.verify_otp_options.id,
      aws_api_gateway_integration.verify_otp_options.id,
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_api_gateway_method" "verify_otp_post" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.verify_otp.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
}
resource "aws_api_gateway_integration" "verify_otp_post" {
  http_method = aws_api_gateway_method.verify_otp_post.http_method
  resource_id = aws_api_gateway_resource.verify_otp.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  type        = "HTTP_PROXY"
  integration_http_method  = "POST"
  uri = "http://api.endpoint.com/proxy"
  passthrough_behavior     = "WHEN_NO_MATCH"
}
resource "aws_api_gateway_method_response" "verify_otp_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.verify_otp.id
  http_method = aws_api_gateway_method.verify_otp_post.http_method
  status_code = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
  response_models = { "application/json" = "Empty"}
}
resource "aws_api_gateway_integration_response" "verify_otp_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.verify_otp.id
  http_method = aws_api_gateway_method.verify_otp_post.http_method
  status_code = aws_api_gateway_method_response.verify_otp_post_response_200.status_code
  response_templates = {
    "application/json" = <<EOF
    #set($inputRoot = $input.path('$'))
    <?xml version="1.0" encoding="UTF-8"?>
    <message>
    $inputRoot.body
    </message>
    EOF
    }
  }
resource "aws_api_gateway_deployment" "verify_otp_post" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers = {
    redeployment = sha1(jsonencode([aws_api_gateway_resource.verify_otp.id,
      aws_api_gateway_method.verify_otp_post.id,
      aws_api_gateway_integration.verify_otp_post.id,
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}
######################################################

resource "aws_api_gateway_resource" "classes" {
  rest_api_id ="${aws_api_gateway_rest_api.api.id}"
  parent_id = "${aws_api_gateway_resource.node.id}"
  path_part = "classes"
}
resource "aws_api_gateway_method" "classes_get" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.classes.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  
}
resource "aws_api_gateway_integration" "classes_get" {
  http_method = aws_api_gateway_method.classes_get.http_method
  resource_id = aws_api_gateway_resource.classes.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  type        = "MOCK"
}

resource "aws_api_gateway_method_response" "classes_get_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.classes.id
  http_method = aws_api_gateway_method.classes_get.http_method
  status_code = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
  response_models = { "application/json" = "Empty"}
}
resource "aws_api_gateway_integration_response" "classes_get_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.classes.id
  http_method = aws_api_gateway_method.classes_get.http_method
  status_code = aws_api_gateway_method_response.classes_get_response_200.status_code
  response_templates = {
    "application/json" = <<EOF
    #set($inputRoot = $input.path('$'))
    <?xml version="1.0" encoding="UTF-8"?>
    <message>
    $inputRoot.body
    </message>
    EOF
    }
  }

resource "aws_api_gateway_deployment" "classes_get" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers = {
    redeployment = sha1(jsonencode([aws_api_gateway_resource.classes.id,
      aws_api_gateway_method.classes_get.id,
      aws_api_gateway_integration.classes_get.id,
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_method" "classes_options" {
  authorization = "NONE"
  http_method   = "OPTIONS"
  resource_id   = aws_api_gateway_resource.classes.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
}
resource "aws_api_gateway_integration" "classes_options" {
  http_method = aws_api_gateway_method.classes_options.http_method
  resource_id = aws_api_gateway_resource.classes.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  type        = "MOCK"
}
resource "aws_api_gateway_method_response" "classes_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.classes.id
  http_method = aws_api_gateway_method.classes_options.http_method
  status_code = "200"
}
resource "aws_api_gateway_integration_response" "classes_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.classes.id
  http_method = aws_api_gateway_method.classes_options.http_method
  status_code = aws_api_gateway_method_response.classes_options_response_200.status_code
}

resource "aws_api_gateway_deployment" "classes_options" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers = {
    redeployment = sha1(jsonencode([aws_api_gateway_resource.classes.id,
      aws_api_gateway_method.classes_options.id,
      aws_api_gateway_integration.classes_options.id,
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}

######################################################

resource "aws_api_gateway_resource" "streams" {
  rest_api_id ="${aws_api_gateway_rest_api.api.id}"
  parent_id = "${aws_api_gateway_resource.node.id}"
  path_part = "streams"
}
resource "aws_api_gateway_method" "streams_get" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.streams.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
}
resource "aws_api_gateway_integration" "streams_get" {
  http_method = aws_api_gateway_method.streams_get.http_method
  resource_id = aws_api_gateway_resource.streams.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  type        = "MOCK"
}

resource "aws_api_gateway_method_response" "streams_get_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.streams.id
  http_method = aws_api_gateway_method.streams_get.http_method
  status_code = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
  response_models = { "application/json" = "Empty"}
}
resource "aws_api_gateway_integration_response" "streams_get_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.streams.id
  http_method = aws_api_gateway_method.streams_get.http_method
  status_code = aws_api_gateway_method_response.streams_get_response_200.status_code
  response_templates = {
    "application/json" = <<EOF
    #set($inputRoot = $input.path('$'))
    <?xml version="1.0" encoding="UTF-8"?>
    <message>
    $inputRoot.body
    </message>
    EOF
    }
  }
resource "aws_api_gateway_deployment" "streams_get" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers = {
    redeployment = sha1(jsonencode([aws_api_gateway_resource.streams.id,
      aws_api_gateway_method.streams_get.id,
      aws_api_gateway_integration.streams_get.id,
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_method" "streams_options" {
  authorization = "NONE"
  http_method   = "OPTIONS"
  resource_id   = aws_api_gateway_resource.streams.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
}
resource "aws_api_gateway_integration" "streams_options" {
  http_method = aws_api_gateway_method.streams_options.http_method
  resource_id = aws_api_gateway_resource.streams.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  type        = "MOCK"
}

resource "aws_api_gateway_method_response" "streams_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.streams.id
  http_method = aws_api_gateway_method.streams_options.http_method
  status_code = "200"
}
resource "aws_api_gateway_integration_response" "streams_options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.streams.id
  http_method = aws_api_gateway_method.streams_options.http_method
  status_code = aws_api_gateway_method_response.streams_options_response_200.status_code
}
resource "aws_api_gateway_deployment" "streams_options" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers = {
    redeployment = sha1(jsonencode([aws_api_gateway_resource.streams.id,
      aws_api_gateway_method.streams_options.id,
      aws_api_gateway_integration.streams_options.id,
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}
######################################################
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id ="${aws_api_gateway_rest_api.api.id}"
  parent_id = "${aws_api_gateway_resource.node.id}"
  path_part = "{proxy+}"
}
resource "aws_api_gateway_method" "proxy" {
  authorization = "NONE"
  http_method   = "ANY"
  resource_id   = aws_api_gateway_resource.proxy.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
}
resource "aws_api_gateway_integration" "proxy" {
  http_method = aws_api_gateway_method.proxy.http_method
  resource_id = aws_api_gateway_resource.proxy.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  type        = "HTTP_PROXY"
  integration_http_method  = "POST"
  uri = "http://api.endpoint.com/proxy"
  passthrough_behavior     = "WHEN_NO_MATCH"
}
resource "aws_api_gateway_method_response" "proxy_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = "200"
}
/*resource "aws_api_gateway_integration_response" "proxy_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = aws_api_gateway_method_response.proxy_response_200.status_code
  response_templates = {
    "application/json" = <<EOF
    #set($inputRoot = $input.path('$'))
    <?xml version="1.0" encoding="UTF-8"?>
    <message>
    $inputRoot.body
    </message>
    EOF
    }
}*/
######################################################

resource "aws_api_gateway_stage" "api" {
  deployment_id = aws_api_gateway_deployment.get_api_options.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "${var.environment}"
}

resource "aws_api_gateway_domain_name" "api" {
  certificate_arn = var.api_certificate_arn
  domain_name     = "${var.api_domain}.${var.main_domain}"
}

resource "aws_route53_record" "api" {
  name    = aws_api_gateway_domain_name.api.domain_name
  type    = "A"
  zone_id = var.zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.api.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.api.cloudfront_zone_id
  }
}

output "api_gateway_arn" {
  description = "ARN of the API_Gatway utilized by the WAF."
  value       = aws_api_gateway_stage.api.arn
}