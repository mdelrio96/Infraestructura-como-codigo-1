# Variables para la configuración de AWS
variable "aws_region" {
  description = "Región de AWS donde se desplegará la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto para etiquetar los recursos"
  type        = string
  default     = "cheese-factory"
}

# Variables para las instancias EC2
variable "instance_count" {
  description = "Número de instancias EC2 a crear"
  type        = number
  default     = 3
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "ID de la AMI de Amazon Linux 2"
  type        = string
  default     = "ami-0c02fb55956c7d316"  # Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type
}

# Variables para las imágenes Docker
variable "docker_images" {
  description = "Lista de imágenes Docker para cada instancia"
  type        = list(string)
  default     = ["errm/cheese:wensleydale", "errm/cheese:cheddar", "errm/cheese:stilton"]
}

# Variable para la IP personal
variable "my_ip" {
  description = "Tu dirección IP para permitir acceso SSH"
  type        = string
  default     = "0.0.0.0/0"  # Cambiar por tu IP real
}

# Variables opcionales para personalización
variable "tags" {
  description = "Tags adicionales para todos los recursos"
  type        = map(string)
  default     = {
    Project   = "Cheese Factory"
    ManagedBy = "Terraform"
    Course    = "Infraestructura como Código"
  }
}
