output "sqs_info" {
  description = "Información de las colas SQS creadas, incluyendo ARN e ID"
  value       = { for k, v in aws_sqs_queue.sqs : k => { "sqs_arn" : v.arn, "sqs_id" : v.id } }
}

output "queue_urls" {
  description = "URLs de las colas SQS creadas"
  value       = { for k, v in aws_sqs_queue.sqs : k => v.url }
}

output "queue_arns" {
  description = "ARNs de las colas SQS creadas"
  value       = { for k, v in aws_sqs_queue.sqs : k => v.arn }
}

output "queue_names" {
  description = "Nombres de las colas SQS creadas"
  value       = { for k, v in aws_sqs_queue.sqs : k => v.name }
}

output "lambda_event_source_mappings" {
  description = "Información de los Lambda triggers configurados, incluyendo UUID y estado"
  value = {
    for k, v in aws_lambda_event_source_mapping.sqs_trigger : k => {
      uuid         = v.uuid
      function_arn = v.function_arn
      state        = v.state
    }
  }
}
