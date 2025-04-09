###########################################
############ SQS module #################
###########################################

module "sqs_queues" {
  source = "../../"
  providers = {
    aws.project = aws.principal
  }

  # Common configuration
  client       = var.client
  functionality = var.project
  environment  = var.environment

  # SQS configuration
  sqs_config = var.sqs_config
}
