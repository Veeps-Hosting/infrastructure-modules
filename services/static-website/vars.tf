# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED MODULE PARAMETERS
# These variables must be passed in by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region in which all resources will be created"
}

variable "aws_account_id" {
  description = "The ID of the AWS Account in which to create resources."
}

variable "website_domain_name" {
  description = "The name of the website and the S3 bucket to create (e.g. static.foo.com)."
}

variable "create_route53_entry" {
  description = "If set to true, create a DNS A Record in Route 53 with the domain name in var.website_domain_name."
}

variable "terraform_state_aws_region" {
  description = "The AWS region of the S3 bucket used to store Terraform remote state"
}

variable "terraform_state_s3_bucket" {
  description = "The name of the S3 bucket used to store Terraform remote state"
}

variable "acm_certificate_domain_name" {
  description = "The domain name for which an ACM cert has been issues (e.g. *.foo.com).  Only used if var.create_route53_entry is true. Set to blank otherwise."
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# These variables have defaults, but may be overridden by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "index_document" {
  description = "The path to the index document in the S3 bucket (e.g. index.html)."
  default     = "index.html"
}

variable "error_document" {
  description = "The path to the error document in the S3 bucket (e.g. error.html)."
  default     = "error.html"
}

variable "default_ttl" {
  description = "The default amount of time, in seconds, that an object is in a CloudFront cache before CloudFront forwards another request in the absence of an 'Cache-Control max-age' or 'Expires' header."
  default     = 30
}

variable "max_ttl" {
  description = "The maximum amount of time, in seconds, that an object is in a CloudFront cache before CloudFront forwards another request to your origin to determine whether the object has been updated. Only effective in the presence of 'Cache-Control max-age', 'Cache-Control s-maxage', and 'Expires' headers."
  default     = 60
}

variable "min_ttl" {
  description = "The minimum amount of time that you want objects to stay in CloudFront caches before CloudFront queries your origin to see whether the object has been updated."
  default     = 0
}
