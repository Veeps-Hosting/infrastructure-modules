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
  description = "The name of the OpenVPN Server and the other resources created by these templates"
}

variable "instance_type" {
  description = "The type of instance to run for the OpenVPN Server"
}

variable "ami" {
  description = "The AMI to run on the OpenVPN Server. This should be built from the Packer template under packer/openvpn-server.json."
}

variable "keypair_name" {
  description = "The name of a Key Pair that can be used to SSH to this instance. Leave blank if you don't want to enable Key Pair auth."
}

variable "allow_ssh_from_cidr_list" {
  description = "A list of IP address ranges in CIDR format from which SSH access will be permitted. Attempts to access the OpenVPN Server from all other IP addresses will be blocked. This is only used if var.allow_ssh_from_cidr is true."
  type        = "list"
}

variable "terraform_state_aws_region" {
  description = "The AWS region of the S3 bucket used to store Terraform remote state"
}

variable "terraform_state_s3_bucket" {
  description = "The name of the S3 bucket used to store Terraform remote state"
}

variable "current_vpc_name" {
  description = "The name of the VPC in which to deploy the OpenVPN Server"
}

variable "other_vpc_names" {
  description = "The name of the other VPCs you have deployed in this account. Requests for IP addresses in these VPCs will be routed over VPN."
  type        = "list"
}

variable "tenancy" {
  description = "The tenancy of this server. Must be one of: default, dedicated, or host."
  default     = "default"
}

variable "request_queue_name" {
  description = "The name of the sqs queue that will be used to receive new certificate requests. Note that the queue name will be automatically prefixed with 'openvpn-requests-'."
}

variable "revocation_queue_name" {
  description = "The name of the sqs queue that will be used to receive certification revocation requests. Note that the queue name will be automatically prefixed with 'openvpn-requests-'."
}

variable "backup_bucket_name" {
  description = "The name of the s3 bucket that will be used to backup PKI secrets"
}

variable "vpn_subnet" {
  description = "The subnet IP and mask vpn clients will be assigned addresses from. For example, 172.16.1.0 255.255.255.0. This is a non-routed network that only exists between the VPN server and the client. Therefore, it should NOT overlap with VPC addressing, or the client won't be able to access any of the VPC IPs. In general, we recommend using internal, non-RFC 1918 IP addresses, such as 172.16.xx.yy."
}

variable "ca_country" {
  description = "The two-letter country code where your organization is located for the Certificate Authority"
}

variable "ca_state" {
  description = "The state or province name where your organization is located for the Certificate Authority"
}

variable "ca_locality" {
  description = "The locality name (e.g. city or town name) where your organization is located for the Certificate Authority"
}

variable "ca_org" {
  description = "The name of your organization (e.g. Gruntwork) for the Certificate Authority"
}

variable "ca_org_unit" {
  description = "The name of the unit, department, or scope within your organization for the Certificate Authority"
}

variable "ca_email" {
  description = "The e-mail address of the administrator for the Certificate Authority"
}

variable "create_route53_entry" {
  description = "Set to true to add var.domain_name as a Route 53 DNS A record for the OpenVPN server"
  default     = false
}

variable "domain_name" {
  description = "The domain name to use for the OpenVPN server. Only used if var.create_route53_entry is true."
  default     = ""
}
