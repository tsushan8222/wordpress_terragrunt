module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "${var.env}-${var.cluster_name}"
  version = "5.11.4"


  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = var.log_group_name
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  services = {
    ecsdemo-frontend = {
      cpu    = 1024
      memory = 4096
      assign_public_ip     = true

      # Container definition(s)
      runtime_platform = {
        cpu_architecture       = "ARM64"
        operating_system_family = "LINUX"
      }

      container_definitions = {

        fluent-bit = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "906394416424.dkr.ecr.us-west-2.amazonaws.com/aws-for-fluent-bit:stable"
          firelens_configuration = {
            type = "fluentbit"
          }
          memory_reservation = 50
        }

        ecs-sample = {
          cpu       = 512
          memory    = 1024
          essential = true
#          image     = "public.ecr.aws/aws-containers/ecsdemo-frontend:776fd50"
          image     = var.image_arn
          port_mappings = [
            {
              name          = "ecs-sample"
              containerPort = 80
              protocol      = "tcp"
            }
          ]

          environment = [
            {
              name  = "WORDPRESS_DB_NAME"
              value = local.wordpress_secret["WORDPRESS_DB_NAME"]
            },
            {
              name  = "WORDPRESS_DB_HOST"
              value = local.wordpress_secret["WORDPRESS_DB_HOST"]
            },
            {
              name  = "WORDPRESS_DB_USER"
              value = local.wordpress_secret["WORDPRESS_DB_USER"]
            },
            {
              name  = "DB_PASSWORD"
              value = local.wordpress_secret["WORDPRESS_DB_PASSWORD"]
            }
          ]

          # Example image used requires access to write to root filesystem
          readonly_root_filesystem = false

          dependencies = [{
            containerName = "fluent-bit"
            condition     = "START"
          }]

          enable_cloudwatch_logging = true
          log_configuration = {
            logDriver = "awsfirelens"
            options = {
              Name                    = "firehose"
              region                  = var.region
              delivery_stream         = "my-stream"
              log-driver-buffer-limit = "2097152"
            }
          }
          memory_reservation = 100
        }
      }

      service_connect_configuration = {
        namespace = aws_service_discovery_private_dns_namespace.example.name
        service = {
          client_alias = {
            port     = 80
            dns_name = "ecs-sample"
          }
          port_name      = "ecs-sample"
          discovery_name = "ecs-sample"
        }
      }

      load_balancer = {
        service = {
          target_group_arn = aws_lb_target_group.example.arn
          container_name   = "ecs-sample"
          container_port   = 80
        }
      }

      ecs_task_execution_role_name = "${var.env}-ecsTaskExecutionRole"
      ecs_task_role_name           = "${var.env}-ecsTaskRole"
       
      # create_task_exec_iam_role	= true
      # create_task_exec_policy	= true

      subnet_ids = var.public_subnets
      security_group_ids = [aws_security_group.lb_sg.id]
      # security_group_rules = {
      #   alb_ingress_3000 = {
      #     type                     = "ingress"
      #     from_port                = 80
      #     to_port                  = 80
      #     protocol                 = "tcp"
      #     description              = "Service port"
      #     source_security_group_id = "sg-12345678"
      #   }
      #   egress_all = {
      #     type        = "egress"
      #     from_port   = 0
      #     to_port     = 0
      #     protocol    = "-1"
      #     cidr_blocks = ["0.0.0.0/0"]
      #   }
      # }

      # Configure Autoscaling
      autoscaling = {
        target_tracking = [
          {
            target_value = 50
            scale_in_cooldown  = 300
            scale_out_cooldown = 300
            predefined_metric_specification = {
              predefined_metric_type = "ECSServiceAverageCPUUtilization"
            }
          },
          {
            target_value = 75
            scale_in_cooldown  = 300
            scale_out_cooldown = 300
            predefined_metric_specification = {
              predefined_metric_type = "ECSServiceAverageMemoryUtilization"
            }
          }
        ]
        min_capacity = 1  # Minimum number of tasks
        max_capacity = 5  # Maximum number of tasks
      }
    }
  }

  tags = {
    Environment = "dev"
    Project     = "terraform"
  }
}

# Fetch the secret from AWS Secrets Manager
data "aws_secretsmanager_secret" "wordpress_secret" {
  secret_id = var.secret
}

# Retrieve the version of the secret
data "aws_secretsmanager_secret_version" "wordpress_secret_version" {
  secret_id = data.aws_secretsmanager_secret.wordpress_secret.id
}


locals {
  wordpress_secret = jsondecode(data.aws_secretsmanager_secret_version.wordpress_secret_version.secret_string)
}