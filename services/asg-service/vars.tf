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
  description = "The name for the ASG and all other resources created by these templates."
}

variable "vpc_name" {
  description = "The name of the VPC in which all the resources should be deployed (e.g. stage, prod)"
}

variable "ami" {
  description = "The ID of the AMI to run on each EC2 Instance in the ASG."
}

variable "init_script_path" {
  description = "The path to an initialization script to execute in User Data while each Instance is booting. This should be a script that's built into var.ami and used to start your service. Terraform will pass several variables to this script, including AWS region, VPC name, and ASG name."
}

variable "instance_type" {
  description = "The type of instance to run in the ASG (e.g. t2.medium)"
}

variable "keypair_name" {
  description = "The name of a Key Pair that can be used to SSH to the EC2 Instances in the ASG. Leave blank if you don't want to enable Key Pair auth."
}

variable "min_size" {
  description = "The minimum number of EC2 Instances to run in this ASG"
}

variable "max_size" {
  description = "The maximum number of EC2 Instances to run in this ASG"
}

variable "desired_capacity" {
  description = "The desired number of EC2 Instances to run in the ASG initially. Note that auto scaling policies may change this value."
}

variable "server_port" {
  description = "The port the EC2 instances listen on for HTTP requests"
}

variable "terraform_state_aws_region" {
  description = "The AWS region of the S3 bucket used to store Terraform remote state"
}

variable "terraform_state_s3_bucket" {
  description = "The name of the S3 bucket used to store Terraform remote state"
}

variable "alb_listener_rule_configs" {
  description = "A list of all ALB Listener Rules that should be attached to an existing ALB Listener. These rules configure the ALB to send requests that come in on certain ports and paths to this service. Each item in the list should be a map with the keys port (the port to match), path (the path to match), and priority (earlier priorities are matched first)."
  type        = "list"

  # Example:
  # default = [
  #   {
  #     port     = 80
  #     path     = "/foo/*"
  #     priority = 100
  #   },
  #   {
  #     port     = 443
  #     path     = "/foo/*"
  #     priority = 100
  #   }
  # ]
}

variable "min_elb_capacity" {
  description = "Wait for this number of EC2 Instances to show up healthy in the load balancer on creation."
}

variable "is_internal_alb" {
  description = "If set to true, create only private DNS entries. We should be able to compute this from the ALB automatically, but can't, due to a Terraform limitation (https://goo.gl/gq5Qyk)."
}

variable "health_check_path" {
  description = "The path, without any leading slash, that can be used as a health check (e.g. healthcheck). Should return a 200 OK when the service is up and running."
}

variable "health_check_protocol" {
  description = "The protocol to use for health checks. Should be one of HTTP, HTTPS."
}

variable "enable_route53_health_check" {
  description = "If set to true, use Route 53 to perform health checks on var.domain_name."
  default     = false
}

variable "db_remote_state_path" {
  description = "The path to the DB's remote state. This path does not need to include the region or VPC name. Example: data-stores/rds/terraform.tfstate."
  default     = "data-stores/rds/terraform.tfstate"
}

variable "create_route53_entry" {
  description = "Set to true to create a DNS A record in Route 53 for this service."
  default     = false
}

variable "domain_name" {
  description = "The domain name to register in var.hosted_zone_id (e.g. foo.example.com). Only used if var.create_route53_entry is true."
  default     = "replace-me"
}
