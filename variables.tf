variable "sqs_config" {
  description = "Configuración de colas SQS"
  type = map(object({
    delay_seconds               = number
    max_message_size            = number
    message_retention_seconds   = number
    receive_wait_time_seconds   = number
    visibility_timeout_seconds  = number
    fifo_queue                  = bool
    kms_master_key_id           = string
    dead_letter_queue           = bool
    statements = list(object({
      sid         = string
      actions     = list(string)
      resources   = list(string)
      effect      = string
      type        = string
      identifiers = list(string)
      condition = list(object({
        test     = string
        variable = string
        values   = list(string)
      }))
    }))
    application = string
    additional_tags = optional(map(string), {})
  }))
  validation {
    condition     = length(var.sqs_config) > 0
    error_message = "Al menos una configuración de cola SQS debe ser proporcionada."
  }
}

variable "functionality" {
  description = "Nombre del proyecto o funcionalidad"
  type        = string
  validation {
    condition     = length(var.functionality) > 0
    error_message = "El nombre de la funcionalidad no puede estar vacío."
  }
}

variable "client" {
  description = "Nombre del cliente para el que se crea el recurso"
  type        = string
  validation {
    condition     = length(var.client) > 0
    error_message = "El nombre del cliente no puede estar vacío."
  }
}

variable "environment" {
  description = "Entorno de despliegue (dev, qa, pdn)"
  type        = string
  validation {
    condition     = contains(["dev", "qa", "pdn"], var.environment)
    error_message = "El entorno debe ser uno de: dev, qa, pdn."
  }
}
