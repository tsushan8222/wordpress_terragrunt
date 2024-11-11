resource "aws_lb" "example" {
  name               = "${var.env}-ecs-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = var.public_subnets

  tags = {
    Name        = "${var.env}-ecs-lb"
    Environment = var.env
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  # HTTP redirect to HTTPS
  default_action {
    type = "redirect"
    redirect {
      protocol = "HTTPS"
      port     = "443"
      status_code = "HTTP_301"
    }
  }

  # default_action {
  #   type             = "forward"
  #   target_group_arn = aws_lb_target_group.example.arn
  # }
}


resource "aws_lb_target_group" "example" {
  name     = "${var.env}-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.example.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy        = "ELBSecurityPolicy-2016-08" # Choose your SSL policy here
  certificate_arn   = var.ssl_certificate_arn # Provide the ARN of your SSL certificate

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}



resource "aws_security_group" "lb_sg" {
  name        = "${var.env}-lb-sg"
  description = "Security group for the ECS Load Balancer"
  vpc_id      = var.vpc_id

  # Allow inbound HTTP traffic from anywhere to the load balancer
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic from the internet"
  }

  # Allow all outbound traffic from the load balancer
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.env}-lb-sg"
    Environment = var.env
  }
}

resource "aws_service_discovery_private_dns_namespace" "example" {
  name        = "example"
  vpc         = var.vpc_id
  description = "Private namespace for ECS service discovery"
}

# resource "aws_security_group_rule" "outbound_https" {
#   type        = "egress"
#   from_port   = 443
#   to_port     = 443
#   protocol    = "tcp"
#   cidr_blocks = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.ecs_task_sg.id
# }


