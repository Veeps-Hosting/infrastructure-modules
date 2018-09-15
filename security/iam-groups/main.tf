# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE A BEST PRACTICES SET OF IAM GROUPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  # The AWS region in which all resources will be created
  region = "${var.aws_region}"

  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${var.aws_account_id}"]
}

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE REMOTE STATE STORAGE
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}

  # Only allow this Terraform version. Note that if you upgrade to a newer version, Terraform won't allow you to use an
  # older version, so when you upgrade, you should upgrade everyone on your team and your CI servers all at once.
  required_version = "= 0.11.7"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE IAM GROUPS
# Create the core set of IAM Groups. See the module for details on which IAM Groups get created.
# This Gruntwork Module allows for much more customization. See the vars.tf file at https://goo.gl/GdHhKs.
# ---------------------------------------------------------------------------------------------------------------------

module "iam_groups" {
  source = "git::git@github.com:gruntwork-io/module-security.git//modules/iam-groups?ref=v0.15.1"

  aws_account_id     = "${var.aws_account_id}"
  should_require_mfa = "${var.should_require_mfa}"

  iam_group_developers_permitted_services = "${var.iam_group_developers_permitted_services}"
  iam_group_developers_s3_bucket_prefix   = "${var.iam_group_developers_s3_bucket_prefix}"

  iam_groups_for_cross_account_access = "${var.iam_groups_for_cross_account_access}"
  cross_account_access_all_group_name = "${var.cross_account_access_all_group_name}"

  should_create_iam_group_billing                = "${var.should_create_iam_group_billing}"
  should_create_iam_group_developers             = "${var.should_create_iam_group_developers}"
  should_create_iam_group_read_only              = "${var.should_create_iam_group_read_only}"
  should_create_iam_group_ssh_grunt_sudo_users   = "${var.should_create_iam_group_ssh_grunt_sudo_users}"
  should_create_iam_group_ssh_grunt_users        = "${var.should_create_iam_group_ssh_grunt_users}"
  should_create_iam_group_use_existing_iam_roles = "${var.should_create_iam_group_use_existing_iam_roles}"
  should_create_iam_group_auto_deploy            = "${var.should_create_iam_group_auto_deploy}"

  auto_deploy_permissions = ["${var.auto_deploy_permissions}"]
}
