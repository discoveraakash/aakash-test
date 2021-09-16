resource "aws_iam_role_policy_attachment" "AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_pod_execution_role.name
}

resource "aws_iam_role" "fargate_pod_execution_role" {
  name                  = "${var.name}-eks-fargate-pod-execution-role"
  force_detach_policies = true

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "eks.amazonaws.com",
          "eks-fargate-pods.amazonaws.com"
          ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_eks_fargate_profile" "main" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "fp-default"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution_role.arn
  subnet_ids             = var.private_subnets.*.id

  selector {
    namespace = "default"
  }

  selector {
    namespace = "dev"
  }

  timeouts {
    create = "30m"
    delete = "60m"
  }
}

output "pod_execution_role" {
  description = "fargate_pod_execution_role for cloudwatch logging "
  value       = aws_iam_role.fargate_pod_execution_role.name
}

resource "kubernetes_namespace" "dev" {
  metadata {
    labels = {
      app = "lcms"
    }
    name = "dev"
  }
  depends_on = [aws_eks_fargate_profile.main]
}

resource "kubernetes_namespace" "stage" {
  metadata {
    labels = {
      app = "lcms"
    }
    name = "stage"
  }
  depends_on = [aws_eks_fargate_profile.main]
}

resource "kubernetes_namespace" "qa" {
  metadata {
    labels = {
      app = "lcms"
    }
    name = "qa"
  }
  depends_on = [aws_eks_fargate_profile.main]
}

resource "kubernetes_deployment" "dev" {
  metadata {
    name      = "lcms-api"
    namespace = "dev"
    labels    = {
      app = "lcms"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "lcms"
      }
    }
  template {
    metadata {
        labels = {
          app = "lcms"
        }
      }
      spec {
        container {
          image = "gcr.io/google_containers/echoserver:1.4"
          image_pull_policy = "Always"
          name  = "lcms-api"
          port {
            container_port = 8085
          }
        }
      }
    }
  }
  depends_on = [aws_eks_fargate_profile.main]
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "lcms-nginx"
    namespace = "dev"
    labels    = {
      app = "lcms"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "lcms"
      }
    }
  template {
    metadata {
        labels = {
          app = "lcms"
        }
      }
      spec {
        container {
          image = "nginx"
          image_pull_policy = "Always"
          name  = "lcms-nginx"
          port {
            container_port = 80
          }
        }
      }
    }
  }
  depends_on = [aws_eks_fargate_profile.main]
}

resource "kubernetes_service" "dev" {
  metadata {
    name      = "lcms-api"
    namespace = "dev"
    annotations = {
    "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb-ip"
    "service.beta.kubernetes.io/aws-load-balancer-internal" = "true"
    }
  }
  spec {
    selector = {
      app = "lcms"
    }
    port {
      name        = "lcms-port"
      port        = 8085
      target_port = 8085
      protocol    = "TCP"
    }
    port {
      name        = "nginx-port"
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
    type = "NodePort"
  }
  depends_on = [kubernetes_deployment.dev]
}

resource "kubernetes_horizontal_pod_autoscaler" "scaler" {
  metadata {
    name = "app-horizontal-scaler"
    namespace = "dev"
  }
  spec {
    max_replicas = 10
    min_replicas = 2

    #selector = {
    #  app = "lcms"
    #}
    scale_target_ref {
      kind      = "Deployment"
      name      = "lcms-api"
    }
    target_cpu_utilization_percentage = 50
  } 
  depends_on = [aws_eks_fargate_profile.main]
}

#####################################################################################
resource "kubernetes_namespace" "aws_observability" {
  metadata {
    annotations = {
      name = "aws-observability"
    }
    labels = {
      aws-observability = "enabled"
    }
    name = "aws-observability"
  }
}

resource "kubernetes_config_map" "aws_logging" {
  metadata {
    name      = "aws-logging"
    namespace = "aws-observability"
  }

  data = {
    "output.conf" = templatefile(
      "${path.module}/output.conf.tpl",
      {
        region  = var.region
        project = var.project
      }
    )
    "parsers.conf" = file("${path.module}/parsers.conf")
  }
}

data "aws_iam_policy_document" "aws_fargate_logging_policy" {
  statement {
    sid = "1"

    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "aws_fargate_logging_policy" {
  name   = "aws_fargate_logging_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.aws_fargate_logging_policy.json
}

resource "aws_iam_role_policy_attachment" "aws_fargate_logging_policy_attach_role" {
  role       = aws_iam_role.fargate_pod_execution_role.name
  policy_arn = aws_iam_policy.aws_fargate_logging_policy.arn
}