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

variable bastion_host_security_group_id {}

variable "instance_type" {
  description = "Instance type, recommended minimum t2.medium"
}

variable "keypair_name" {
  description = "The AWS EC2 Keypair name for root access to the puppet master."
}

variable "vpc_id" {
  description = "The ID of the VPC in which to run the puppet master. If using the standard Gruntwork VPC setup, this should be the id of the Mgmt VPC."
}

variable "subnet_id" {
  description = "The id of the subnet in which to run the puppet master. If using the standard Gruntwork VPC setup, this should be the id of a public subnet in the Mgmt VPC."
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
