# Outputs para mostrar información importante después del despliegue

output "alb_dns_name" {
  description = "DNS name del Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID del Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "web_url" {
  description = "URL para acceder a la aplicación web"
  value       = "http://${aws_lb.main.dns_name}"
}

output "instance_public_ips" {
  description = "IPs públicas de las instancias EC2"
  value       = aws_instance.web_instances[*].public_ip
}

output "instance_private_ips" {
  description = "IPs privadas de las instancias EC2"
  value       = aws_instance.web_instances[*].private_ip
}

output "instance_ids" {
  description = "IDs de las instancias EC2"
  value       = aws_instance.web_instances[*].id
}

output "target_group_arn" {
  description = "ARN del Target Group"
  value       = aws_lb_target_group.web_tg.arn
}

output "security_group_ids" {
  description = "IDs de los Security Groups creados"
  value = {
    web_sg = aws_security_group.web_sg.id
    alb_sg = aws_security_group.alb_sg.id
  }
}

output "deployment_summary" {
  description = "Resumen del despliegue"
  value = {
    project_name     = var.project_name
    region          = var.aws_region
    instance_count  = var.instance_count
    instance_type   = var.instance_type
    docker_images   = var.docker_images
    alb_dns_name    = aws_lb.main.dns_name
    web_url         = "http://${aws_lb.main.dns_name}"
  }
}
