# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region in which all resources will be created"
}

variable "aws_account_id" {
  description = "The ID of the AWS Account in which to create resources."
}

variable "instance_type" {
  description = "Instance type, recommended minimum t2.medium"
}

variable "backup_job_metric_namespace" {
  description = "The namespace for the CloudWatch Metric the AWS lambda backup job will increment every time the job completes successfully."
  default     = "Custom/Puppetmaster"
}

variable "backup_job_metric_name" {
  description = "The name for the CloudWatch Metric the AWS lambda backup job will increment every time the job completes successfully."
  default     = "puppetmaster-backup-job"
}

variable "backup_schedule_expression" {
  description = "A cron or rate expression that specifies how often to take a snapshot of the Puppetmaster server for backup purposes. See https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html for syntax details."
  default     = "rate(1 day)"
}

variable "backup_job_alarm_period" {
  description = "How often, in seconds, the backup job is expected to run. This is the same as var.backup_schedule_expression, but unfortunately, Terraform offers no way to convert rate expressions to seconds. We add a CloudWatch alarm that triggers if the value of var.backup_job_metric_name and var.backup_job_metric_namespace isn't updated within this time period, as that indicates the backup failed to run."

  # One day in seconds
  default = 86400
}

variable "keypair_name" {
  description = "The AWS EC2 Keypair name for root access to the puppet master."
}

variable "vpc_id" {
  description = "The ID of the VPC in which to run the puppet master. If using the standard Gruntwork VPC setup, this should be the id of the Mgmt VPC."
}

variable "vpc_name" {
  description = "The name of the VPC in which to deploy Puppetmaster"
}

variable "subnet_id" {
  description = "The id of the subnet in which to run the puppet master. If using the standard Gruntwork VPC setup, this should be the id of a public subnet in the Mgmt VPC."
}

variable "terraform_state_aws_region" {
  description = "The AWS region of the S3 bucket used to store Terraform remote state"
}

variable "terraform_state_s3_bucket" {
  description = "The name of the S3 bucket used to store Terraform remote state"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEFINE CONSTANTS
# Generally, these values won't need to be changed.
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the puppetmaster"
  default = "puppet"
}

variable "ami" {
  description = "The ID of the AMI to run on the puppet master Instance."
  # Ubuntu Server 18.04 LTS (HVM), SSD Volume Type in ap-southeast-2
  default = "ami-07a3bd4944eb120a0"
}
