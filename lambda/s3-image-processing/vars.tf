# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region to deploy to (e.g. us-east-1)"
}

variable "aws_account_id" {
  description = "The ID of the AWS Account in which to create resources."
}

variable "name" {
  description = "The name to use for the Lambda function"
}

variable "bucket_name" {
  description = "The name for the S3 bucket where we will store images for the Lambda function to process"
}
