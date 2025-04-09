data "aws_caller_identity" "current" {
  provider = aws.project
}

data "aws_region" "current" {
  provider = aws.project
}

locals {
  # Generar nombres de colas de forma más simple
  queue_names = {
    for k, v in var.sqs_config : k => {
      standard_name = "${var.client}-${var.functionality}-${var.environment}-${v["dead_letter_queue"] ? "dlq" : "sqs"}-${k}"
      fifo_name = "${var.client}-${var.functionality}-${var.environment}-${v["dead_letter_queue"] ? "dlq" : "sqs"}-${k}.fifo"
      final_name = v["fifo_queue"] ? "${var.client}-${var.functionality}-${var.environment}-${v["dead_letter_queue"] ? "dlq" : "sqs"}-${k}.fifo" : "${var.client}-${var.functionality}-${var.environment}-${v["dead_letter_queue"] ? "dlq" : "sqs"}-${k}"
    }
  }
}

resource "aws_sqs_queue" "sqs" {
  provider = aws.project
  for_each = var.sqs_config

  # Usar el nombre generado en locals
  name = local.queue_names[each.key].final_name

  # Configuración de la cola
  delay_seconds              = each.value["delay_seconds"]
  max_message_size           = each.value["max_message_size"]
  message_retention_seconds  = each.value["message_retention_seconds"]
  receive_wait_time_seconds  = each.value["receive_wait_time_seconds"]
  visibility_timeout_seconds = each.value["visibility_timeout_seconds"]
  fifo_queue                 = each.value["fifo_queue"]
  
  # Seguridad en reposo - Cifrado
  sqs_managed_sse_enabled    = each.value["kms_master_key_id"] == "" ? true : null
  kms_master_key_id          = each.value["kms_master_key_id"] != "" ? each.value["kms_master_key_id"] : null

  # Etiquetas - Solo Name y etiquetas adicionales específicas para este recurso
  tags = merge(
    {
      Name = local.queue_names[each.key].final_name
    },
    each.value["additional_tags"]
  )
}

# Configuración de políticas de acceso para las colas SQS
resource "aws_sqs_queue_policy" "sqs_policy" {
  provider = aws.project
  for_each  = var.sqs_config
  queue_url = aws_sqs_queue.sqs[each.key].id
  policy    = data.aws_iam_policy_document.combined[each.key].json
}

# Política base que permite acceso completo al propietario de la cuenta
data "aws_iam_policy_document" "root_policy" {
  provider = aws.project
  for_each = var.sqs_config

  statement {
    sid       = "__owner_statement"
    actions   = ["SQS:*"]
    resources = [
      "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${local.queue_names[each.key].final_name}"
    ]
    effect    = "Allow"
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }
}

# Políticas dinámicas definidas por el usuario
data "aws_iam_policy_document" "dynamic_policy" {
  provider = aws.project
  for_each = var.sqs_config

  dynamic "statement" {
    for_each = each.value["statements"]
    content {
      sid       = statement.value["sid"]
      actions   = statement.value["actions"]
      resources = statement.value["resources"]
      effect    = statement.value["effect"]
      principals {
        type        = statement.value["type"]
        identifiers = statement.value["identifiers"]
      }

      dynamic "condition" {
        for_each = statement.value["condition"]
        content {
          test     = condition.value["test"]
          variable = condition.value["variable"]
          values   = condition.value["values"]
        }
      }
    }
  }
}

# Combinación de políticas base y dinámicas
data "aws_iam_policy_document" "combined" {
  provider = aws.project
  for_each = var.sqs_config
  
  override_policy_documents = [
    data.aws_iam_policy_document.root_policy[each.key].json,
    data.aws_iam_policy_document.dynamic_policy[each.key].json
  ]
}
