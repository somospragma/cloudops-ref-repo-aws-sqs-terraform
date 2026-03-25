###########################################
############### Outputs ###################
###########################################

output "sqs_info" {
  description = "Información de las colas SQS creadas, incluyendo ARN e ID"
  value       = module.sqs_queues.sqs_info
}

output "queue_urls" {
  description = "URLs de las colas SQS creadas"
  value       = module.sqs_queues.queue_urls
}

output "queue_arns" {
  description = "ARNs de las colas SQS creadas"
  value       = module.sqs_queues.queue_arns
}

output "lambda_event_source_mappings" {
  description = "Información de los Lambda triggers configurados"
  value       = module.sqs_queues.lambda_event_source_mappings
}
