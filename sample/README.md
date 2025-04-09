# Ejemplos de Implementación del Módulo SQS

Este directorio contiene ejemplos de implementación del módulo de Amazon SQS siguiendo los estándares de Pragma CloudOps.

## Estructura del Directorio

```
sample/
└── sqs/
    ├── main.tf          # Archivo principal que llama al módulo SQS
    ├── variables.tf     # Definición de variables para el ejemplo
    ├── outputs.tf       # Outputs del ejemplo
    ├── providers.tf     # Configuración de proveedores AWS
    ├── data.tf          # Recursos de datos y recursos auxiliares
    └── terraform.tfvars.sample  # Ejemplo de valores para las variables
```

## Uso del Ejemplo

1. Navega al directorio del ejemplo:
   ```bash
   cd sample/sqs
   ```

2. Crea un archivo `terraform.tfvars` basado en el ejemplo:
   ```bash
   cp terraform.tfvars.sample terraform.tfvars
   ```

3. Edita el archivo `terraform.tfvars` para ajustar los valores según tus necesidades:
   - Actualiza el perfil AWS
   - Configura la región AWS
   - Ajusta los valores de las colas SQS
   - Configura las acciones de alarma

4. Inicializa Terraform:
   ```bash
   terraform init
   ```

5. Verifica el plan de ejecución:
   ```bash
   terraform plan
   ```

6. Aplica la configuración:
   ```bash
   terraform apply
   ```

## Ejemplos Incluidos

El archivo `terraform.tfvars.sample` incluye ejemplos para:

1. **Cola SQS estándar** con su correspondiente cola de letra muerta (DLQ)
2. **Cola SQS FIFO** con su correspondiente cola de letra muerta (DLQ)
3. **Configuración de políticas de acceso** para permitir que servicios como Lambda y SNS interactúen con las colas
4. **Configuración de alarmas** para monitorear la profundidad de las colas y los mensajes en las DLQ

## Personalización

Puedes personalizar este ejemplo modificando:

- La configuración de las colas SQS en `terraform.tfvars`
- Las políticas de acceso para las colas
- Los umbrales de las alarmas
- Las acciones de las alarmas

## Notas Importantes

- Asegúrate de tener los permisos adecuados en AWS para crear estos recursos
- Las colas FIFO tienen un rendimiento limitado en comparación con las colas estándar
- Considera los costos asociados con el uso de SQS y CloudWatch Alarms

Este módulo ha sido desarrollado siguiendo los estándares de Pragma CloudOps, garantizando una implementación segura, escalable y optimizada que cumple con todas las políticas de la organización. Pragma CloudOps recomienda revisar este código con su equipo de infraestructura antes de implementarlo en producción.
