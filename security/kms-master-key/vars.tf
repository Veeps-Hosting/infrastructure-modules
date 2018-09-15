# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables are required. A value must be passed in.
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region in which all resources will be created"
}

variable "aws_account_id" {
  description = "The ID of the AWS Account in which to create resources."
}

variable "cmk_name" {
  description = "What should the master key be called (e.g. config-secrets-stage)?"
}

variable "cmk_administrator_iam_arns" {
  description = "A list of IAM ARNs for users who should be given administrator access to this KMS Master Key (e.g. arn:aws:iam::1234567890:user/foo)."
  type        = "list"
}

variable "cmk_user_iam_arns" {
  description = "A list of IAM ARNs for users who should be given permissions to use this KMS Master Key (e.g. arn:aws:iam::1234567890:user/foo)."
  type        = "list"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have default values that may be overwritten.
# ---------------------------------------------------------------------------------------------------------------------

variable "allow_manage_key_permissions_with_iam" {
  description = "If true, an IAM Policy can be used to assign permissions to this key. If false, only the users explicitly listed in var.cmk_administrator_iam_arns and var.cmk_user_iam_arns will have access to this KMS Key."
  default     = true
}
