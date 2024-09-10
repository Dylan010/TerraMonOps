# Monitoreo de Instancias AWS

Este proyecto implementa un sistema de monitoreo para instancias EC2 en AWS utilizando Terraform, Ansible, Python, Prometheus y Grafana.

## Descripción del Proyecto

El proyecto consta de los siguientes componentes:

1. **Terraform**: Crea la infraestructura en AWS, incluyendo VPC, subnet, Internet Gateway, Security Groups, y las instancias EC2.
2. **Ansible**: Configura las instancias EC2, instalando las dependencias necesarias y desplegando el script de monitoreo.
3. **Python**: Un script que recopila métricas de CPU y memoria de las instancias.
4. **Prometheus**: Recolecta las métricas expuestas por el script de Python.
5. **Grafana**: Visualiza las métricas recolectadas por Prometheus.

## Requisitos Previos

- AWS CLI configurado con las credenciales adecuadas
- Terraform instalado
- Ansible instalado
- Docker instalado (para Prometheus y Grafana)

## Pasos de Implementación

1. **Configurar y Ejecutar Terraform**
   ```
   cd terraform
   terraform init
   terraform apply
   ```
   Esto creará la infraestructura en AWS y generará una nueva clave SSH.

2. **Configurar Ansible**
   - Actualiza el archivo `ansible/inventory.yml` con las IPs públicas de las instancias EC2 creadas por Terraform.
   - Asegúrate de que la ruta de la clave privada en `inventory.yml` coincida con la salida de Terraform.

3. **Ejecutar Ansible**
   ```
   cd ../ansible
   ansible-playbook -i inventory.yml playbook.yml
   ```
   Esto configurará las instancias EC2 e instalará el script de monitoreo.

4. **Configurar y Ejecutar Prometheus**
   ```
   cd ../prometheus
   docker build -t monitoring-prometheus .
   docker run -d -p 9090:9090 monitoring-prometheus
   ```

5. **Configurar y Ejecutar Grafana**
   ```
   cd ../grafana
   docker build -t monitoring-grafana .
   docker run -d -p 3000:3000 monitoring-grafana
   ```

6. **Configurar Grafana Dashboard**
   - Accede a Grafana en `http://localhost:3000` (usuario: admin, contraseña: admin123)
   - Añade Prometheus como fuente de datos (URL: http://host.docker.internal:9090)
   - Crea un nuevo dashboard para visualizar las métricas de CPU y memoria

## Notas Importantes

- Prometheus y Grafana se ejecutan en contenedores Docker en tu máquina local.
- Prometheus accede a las instancias EC2 a través de sus IPs públicas en el puerto 8000.
- Asegúrate de que el Security Group permita el tráfico entrante en el puerto 8000 desde la IP de tu máquina local.
- La clave SSH generada por Terraform se guarda localmente. Asegúrate de protegerla adecuadamente.

## Limpieza

Para eliminar todos los recursos creados en AWS:

```
cd terraform
terraform destroy
```

Asegúrate de detener y eliminar los contenedores Docker de Prometheus y Grafana.