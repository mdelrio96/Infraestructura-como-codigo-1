# Configuración del proveedor AWS
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source para obtener las zonas de disponibilidad
data "aws_availability_zones" "available" {
  state = "available"
}

# Security Group para las instancias EC2
resource "aws_security_group" "web_sg" {
  name_prefix = "${var.project_name}-web-sg"
  description = "Security group for web instances"

  # Permitir tráfico HTTP desde el ALB
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
    description     = "HTTP from ALB"
  }

  # Permitir SSH desde tu IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
    description = "SSH from my IP"
  }

  # Permitir todo el tráfico saliente
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}

# Security Group para el Application Load Balancer
resource "aws_security_group" "alb_sg" {
  name_prefix = "${var.project_name}-alb-sg"
  description = "Security group for Application Load Balancer"

  # Permitir tráfico HTTP desde cualquier lugar
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from anywhere"
  }

  # Permitir todo el tráfico saliente
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# Procesar el script de user_data usando templatefile con índice de instancia
locals {
  user_data_scripts = [
    for i in range(var.instance_count) : base64encode(templatefile("${path.module}/user_data.sh", {
      docker_images = var.docker_images
      project_name  = var.project_name
      instance_index = i
    }))
  ]
}

# Crear las tres instancias EC2
resource "aws_instance" "web_instances" {
  count                  = var.instance_count
  ami                    = var.ami_id
  instance_type          = var.instance_type
  availability_zone      = data.aws_availability_zones.available.names[count.index]
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data              = local.user_data_scripts[count.index]

  tags = {
    Name      = "${var.project_name}-web-${count.index + 1}"
    Cheese    = element(var.docker_images, count.index)
    IsPrimary = count.index == 0 ? "true" : "false"  # Expresión condicional
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.default.ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# Data source para obtener las subnets por defecto
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Data source para obtener la VPC por defecto
data "aws_vpc" "default" {
  default = true
}

# Target Group para el ALB
resource "aws_lb_target_group" "web_tg" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}

# Listener del ALB
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# Attachment de las instancias al Target Group
resource "aws_lb_target_group_attachment" "web_attachment" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web_instances[count.index].id
  port             = 80
}
