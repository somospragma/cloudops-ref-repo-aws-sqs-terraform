###########################################
########## Common variables ###############
###########################################

variable "profile" {
  type        = string
  description = "Profile name containing the access credentials to deploy the infrastructure on AWS"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to be applied to the resources"
}

variable "aws_region" {
  type        = string
  description = "AWS region where resources will be deployed"
}

variable "environment" {
  type        = string
  description = "Environment where resources will be deployed"
  validation {
    condition     = contains(["dev", "qa", "pdn"], var.environment)
    error_message = "El entorno debe ser uno de: dev, qa, pdn."
  }
}

variable "client" {
  type        = string
  description = "Client name"
}

variable "project" {
  type        = string
  description = "Project name"
}

###########################################
############ SQS variables ###############
###########################################

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
    application    = string
    additional_tags = optional(map(string), {})
  }))
}
