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

variable "name" {
  description = "The name of the puppetmaster and the other resources created by these templates"
}

variable "instance_type" {
  description = "The type of instance to run for the puppetmaster"
}

variable "ami" {
  description = "The AMI to run on the puppetmaster."
}

variable "keypair_name" {
  description = "The name of a Key Pair that can be used to SSH to this instance. Leave blank if you don't want to enable Key Pair auth."
}

variable "allow_ssh_from_cidr_list" {
  description = "A list of IP address ranges in CIDR format from which SSH access will be permitted. Attempts to access the puppetmaster from all other IP addresses will be blocked. This is only used if var.allow_ssh_from_cidr is true."
  type        = "list"
}

variable "terraform_state_aws_region" {
  description = "The AWS region of the S3 bucket used to store Terraform remote state"
}

variable "terraform_state_s3_bucket" {
  description = "The name of the S3 bucket used to store Terraform remote state"
}

variable "vpc_name" {
  description = "The name of the VPC in which to deploy the puppetmaster"
  default     = "mgmt"
}

variable "tenancy" {
  description = "The tenancy of this server. Must be one of: default, dedicated, or host."
  default     = "default"
}

variable "domain_name" {
  description = "The domain name to use for the puppetmaster server"
}
