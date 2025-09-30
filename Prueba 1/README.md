# The Cheese Factory - Infraestructura como Código

Este proyecto despliega una arquitectura web simple, escalable y segura en Amazon Web Services utilizando Terraform para "The Cheese Factory", una startup que ofrece una aplicación web para mostrar diferentes tipos de quesos.

## Arquitectura

La infraestructura incluye:

- **3 instancias EC2** (t2.micro) distribuidas en diferentes zonas de disponibilidad
- **Application Load Balancer (ALB)** para distribuir el tráfico
- **Security Groups** configurados para permitir tráfico HTTP y SSH
- **Contenedores Docker** ejecutándose en cada instancia con diferentes tipos de queso:
  - Instancia 1: Wensleydale
  - Instancia 2: Cheddar  
  - Instancia 3: Stilton

## Requisitos Previos

1. **AWS CLI** configurado con credenciales válidas
2. **Terraform** instalado (versión >= 1.0)
3. **Git** para gestión del código
4. Acceso a una cuenta de AWS con permisos suficientes

## Configuración Inicial

### 1. Clonar el repositorio
```bash
git clone <tu-repositorio>
cd <directorio-del-proyecto>
```

### 2. Inicializar Terraform
```bash
terraform init
```

### 3. Revisar el plan de despliegue
```bash
terraform plan
```

### 4. Aplicar la configuración
```bash
terraform apply
```

## Estructura del Proyecto

```
├── main.tf                   # Configuración principal de la infraestructura
├── variables.tf              # Definición de variables
├── outputs.tf                # Outputs del despliegue
├── terraform.tfvars.example  # Archivo de ejemplo para variables
├── user_data.sh              # Script de configuración para instancias EC2
└── README.md                 # Este archivo
```

### Variables
- Variables para región AWS, tipo de instancia, imágenes Docker, etc.
- Script `user_data.sh` que usa variables de Terraform con `templatefile()`
- Valores por defecto definidos en `variables.tf`
- Archivo `terraform.tfvars` para personalizar valores

### ⚠️ Importante: Prueba del Round-Robin

Para probar correctamente el funcionamiento del round-robin del ALB (distribución entre los diferentes tipos de queso):

1. **Usa navegador en modo incógnito** para evitar problemas de caché
2. **Para refrescar la página**, usa **Ctrl+F5** (recarga forzada) en lugar de F5 normal
3. **Comportamiento esperado**:
    - 1ª recarga → Wensleydale
    - 2ª recarga → Cheddar
    - 3ª recarga → Stilton
    - 4ª recarga → Wensleydale (ciclo completo)

**Nota**: El F5 normal puede mantener caché y mostrar siempre el mismo queso. El Ctrl+F5 fuerza una nueva conexión al ALB y permite ver la distribución correcta.

### Ver outputs
```bash
terraform output
```

## Acceso a la Aplicación

Después del despliegue exitoso, puedes acceder a la aplicación web usando la URL del Application Load Balancer que se muestra en los outputs:

```bash
terraform output web_url
```
### Destruir la infraestructura
```bash
terraform destroy
```








```





