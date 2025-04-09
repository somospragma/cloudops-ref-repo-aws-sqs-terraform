# Módulo Terraform para AWS SQS

Este módulo permite crear y configurar colas Amazon SQS (Simple Queue Service) con todas las mejores prácticas de seguridad, nomenclatura y configuración según los estándares.

## Características

- Creación de colas SQS estándar y FIFO
- Soporte para colas de letra muerta (DLQ)
- Cifrado en reposo con AWS KMS
- Políticas de acceso personalizables
- Nomenclatura y etiquetado estandarizado

## Uso

```hcl
module "sqs_queues" {
  source = "/ruta/al/modulo/sqs"
  providers = {
    aws.project = aws.principal  # Mapeo del proveedor con alias
  }

  client       = "pragma"
  functionality = "payments"
  environment  = "dev"

  sqs_config = {
    "orders" = {
      application               = "orders"
      delay_seconds             = 0
      max_message_size          = 262144
      message_retention_seconds = 345600
      receive_wait_time_seconds = 0
      visibility_timeout_seconds = 30
      fifo_queue                = false
      kms_master_key_id         = "alias/aws/sqs"
      dead_letter_queue         = false
      statements = [
        {
          sid         = "AllowLambdaAccess"
          actions     = ["sqs:SendMessage", "sqs:ReceiveMessage", "sqs:DeleteMessage"]
          resources   = ["*"]
          effect      = "Allow"
          type        = "Service"
          identifiers = ["lambda.amazonaws.com"]
          condition   = []
        }
      ]
      additional_tags = {
        service-tier = "standard"
        backup-policy = "none"
      }
    },
    "orders-dead-letter" = {
      application               = "orders"
      delay_seconds             = 0
      max_message_size          = 262144
      message_retention_seconds = 1209600
      receive_wait_time_seconds = 0
      visibility_timeout_seconds = 30
      fifo_queue                = false
      kms_master_key_id         = "alias/aws/sqs"
      dead_letter_queue         = true
      statements                = []
      additional_tags = {
        service-tier = "standard"
        backup-policy = "none"
      }
    }
  }
}
```

## Configuración del proveedor AWS

Este módulo requiere un proveedor AWS con alias. Debes configurar el proveedor en tu archivo `providers.tf` y luego mapearlo al llamar al módulo:

1. **En el módulo principal** (donde defines tus recursos):

```hcl
# providers.tf
provider "aws" {
  alias   = "principal"
  region  = var.aws_region
  profile = var.profile
  
  default_tags {
    tags = var.common_tags
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.31.0"
    }
  }
}
```

2. **En el archivo donde llamas al módulo**:

```hcl
# main.tf
module "sqs_queues" {
  source = "/ruta/al/modulo/sqs"
  providers = {
    aws.project = aws.principal  # Mapeo del proveedor con alias
  }
  
  # Resto de la configuración...
}
```

## Inputs

| Nombre | Descripción | Tipo | Requerido | Default |
|--------|-------------|------|----------|---------|
| client | Nombre del cliente para el que se crea el recurso | string | sí | - |
| functionality | Nombre del proyecto o funcionalidad | string | sí | - |
| environment | Entorno de despliegue (dev, qa, pdn) | string | sí | - |
| sqs_config | Mapa de configuraciones para colas SQS | map(object) | sí | - |

### Estructura de sqs_config

```hcl
sqs_config = {
  "nombre-cola" = {
    application               = string
    delay_seconds             = number
    max_message_size          = number
    message_retention_seconds = number
    receive_wait_time_seconds = number
    visibility_timeout_seconds = number
    fifo_queue                = bool
    kms_master_key_id         = string
    dead_letter_queue         = bool
    statements = [
      {
        sid         = string
        actions     = list(string)
        resources   = list(string)
        effect      = string
        type        = string
        identifiers = list(string)
        condition = [
          {
            test     = string
            variable = string
            values   = list(string)
          }
        ]
      }
    ]
    additional_tags = {       # Opcional - Etiquetas adicionales específicas para este recurso
      key1 = "value1"
      key2 = "value2"
    }
  }
}
```

### Convenciones de nomenclatura

Para evitar problemas con los nombres de las colas, siga estas convenciones:

1. **Colas estándar**: Use nombres descriptivos sin sufijos especiales
   ```
   "orders" -> "pragma-payments-dev-sqs-orders"
   ```

2. **Colas de letra muerta (DLQ)**: Use nombres descriptivos y establezca `dead_letter_queue = true`
   ```
   "orders-dead-letter" -> "pragma-payments-dev-dlq-orders-dead-letter"
   ```

3. **Colas FIFO**: Use nombres descriptivos y establezca `fifo_queue = true` (el sufijo `.fifo` se añade automáticamente)
   ```
   "notifications" (con fifo_queue = true) -> "pragma-payments-dev-sqs-notifications.fifo"
   ```

4. **Colas de letra muerta FIFO**: Combine las convenciones anteriores
   ```
   "notifications-dead-letter" (con fifo_queue = true, dead_letter_queue = true) -> "pragma-payments-dev-dlq-notifications-dead-letter.fifo"
   ```

> **Nota**: Evite incluir "dlq" en las claves de su configuración cuando ya está estableciendo `dead_letter_queue = true`, ya que esto podría resultar en nombres duplicados.

## Cifrado con KMS

El módulo permite configurar el cifrado de las colas SQS utilizando AWS KMS. Para el campo `kms_master_key_id` puedes especificar:

1. **Clave administrada por AWS para SQS**:
   ```hcl
   kms_master_key_id = "alias/aws/sqs"
   ```

2. **Clave personalizada** (usando cualquiera de estos formatos):
   - ARN completo: `arn:aws:kms:region:account-id:key/key-id`
   - ID de clave: `key-id`
   - Alias de clave: `alias/nombre-del-alias`

3. **Cifrado administrado por SQS**:
   - Dejar el campo vacío: `kms_master_key_id = ""`

> **Nota**: Cuando se utiliza un alias, siempre debe incluirse el prefijo `alias/`.

## Etiquetado

El módulo maneja el etiquetado de la siguiente manera:

1. **Etiquetas obligatorias**: Se aplican a través del provider AWS usando `default_tags` en la configuración del provider.
   ```hcl
   provider "aws" {
     default_tags {
       tags = {
         environment = "dev"
         project     = "payments"
         owner       = "cloudops"
         client      = "pragma"
         area        = "infrastructure"
         provisioned = "terraform"
         datatype    = "operational"
       }
     }
   }
   ```

   > **Nota**: Todas las etiquetas obligatorias se proporcionan a través de `default_tags` en el proveedor AWS, lo que asegura una aplicación consistente en todos los recursos.

2. **Etiqueta Name**: Se genera automáticamente siguiendo el estándar de nomenclatura para cada recurso.

3. **Etiquetas adicionales por recurso**: Se pueden especificar etiquetas adicionales para cada cola SQS individualmente mediante el atributo `additional_tags` en la configuración de cada cola.

## Monitoreo

> **Nota importante**: Este módulo no incluye la creación de alarmas CloudWatch. Para implementar monitoreo y alertas, se recomienda utilizar el módulo específico de CloudWatch de Pragma CloudOps, que permite configurar alarmas para métricas de SQS como:
>
> - ApproximateNumberOfMessagesVisible (profundidad de cola)
> - ApproximateAgeOfOldestMessage (edad del mensaje más antiguo)
> - NumberOfMessagesReceived (mensajes recibidos)
> - NumberOfMessagesSent (mensajes enviados)
> - NumberOfMessagesDeleted (mensajes eliminados)
>
> Para las colas de letra muerta (DLQ), es especialmente importante configurar alarmas para la métrica `ApproximateNumberOfMessagesVisible` con un umbral de 0, para recibir alertas cuando haya mensajes en la DLQ.

## Outputs

| Nombre | Descripción |
|--------|-------------|
| sqs_info | Información de las colas SQS creadas, incluyendo ARN e ID |
| queue_urls | URLs de las colas SQS creadas |
| queue_arns | ARNs de las colas SQS creadas |
| queue_names | Nombres de las colas SQS creadas |

## Mejores Prácticas Implementadas

- **Seguridad**: Cifrado en reposo con AWS KMS
- **Nomenclatura**: Estándar {client}-{functionality}-{environment}-{resource-type}-{resource-name}
- **Etiquetado**: Etiquetas completas según política (environment, project, owner, client) a través de `default_tags`
- **Modularización**: Estructura modular y reutilizable

## Configuración del Backend

> **Recomendación importante**: Para entornos de producción y colaboración en equipo, se recomienda configurar un backend remoto para almacenar el estado de Terraform (tfstate). Esto proporciona:
>
> - Bloqueo de estado para prevenir operaciones concurrentes
> - Respaldo y versionado del estado
> - Almacenamiento seguro de información sensible
> - Colaboración en equipo
>
> Ejemplo de configuración con S3 y DynamoDB:
>
> ```hcl
> terraform {
>   backend "s3" {
>     bucket         = "pragma-terraform-states"
>     key            = "sqs/terraform.tfstate"
>     region         = "us-east-1"
>     encrypt        = true
>     dynamodb_table = "terraform-locks"
>   }
> }
> ```
>
> Asegúrese de que el bucket S3 tenga el versionado habilitado y que la tabla DynamoDB tenga una clave primaria llamada `LockID`.

## Lista de verificación de cumplimiento

- [x] Nomenclatura de recursos conforme al estándar
- [x] Etiquetas obligatorias aplicadas a todos los recursos
- [x] Cifrado en tránsito y en reposo implementado
- [ ] Monitoreo y alertas (debe implementarse con el módulo CloudWatch)
- [x] Acceso de red restringido según principio de mínimo privilegio
- [x] Documentación actualizada
- [x] Estrategia de backup configurada (N/A para SQS)
- [x] Revisión de seguridad completada

Este módulo ha sido desarrollado siguiendo los estándares de Pragma CloudOps, garantizando una implementación segura, escalable y optimizada que cumple con todas las políticas de la organización. Pragma CloudOps recomienda revisar este código con su equipo de infraestructura antes de implementarlo en producción.
