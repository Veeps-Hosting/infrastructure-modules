# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# LAUNCH AN AURORA RDS CLUSTER
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
  required_version = "= 0.11.8"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE AURORA RDS CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "database" {
  source = "git::git@github.com:gruntwork-io/module-data-storage.git//modules/aurora?ref=v0.6.7"

  name   = "${var.name}"
  port   = "${var.port}"
  engine = "${var.engine}"

  db_name = "${var.db_name}"

  master_username = "${var.master_username}"
  master_password = "${var.master_password}"

  # Run in the private persistence subnets and only allow incoming connections from the private app subnets
  vpc_id                                 = "${data.terraform_remote_state.vpc.vpc_id}"
  subnet_ids                             = ["${data.terraform_remote_state.vpc.private_persistence_subnet_ids}"]
  allow_connections_from_cidr_blocks     = ["${data.terraform_remote_state.vpc.private_app_subnet_cidr_blocks}"]
  allow_connections_from_security_groups = "${compact(list(var.allow_connections_from_bastion_host ? data.terraform_remote_state.bastion_host.bastion_host_security_group_id : ""))}"

  storage_encrypted = "${var.storage_encrypted}"
  kms_key_arn       = "${data.terraform_remote_state.kms_master_key.key_arn}"

  instance_count = "${var.instance_count}"
  instance_type  = "${var.instance_type}"

  backup_retention_period = "${var.backup_retention_period}"
  apply_immediately       = "${var.apply_immediately}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ADD CLOUDWATCH ALARMS FOR THE AURORA CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "rds_alarms" {
  source               = "git::git@github.com:gruntwork-io/module-aws-monitoring.git//modules/alarms/rds-alarms?ref=v0.9.1"
  rds_instance_ids     = ["${module.database.instance_ids}"]
  num_rds_instance_ids = "${var.instance_count}"
  is_aurora            = true
  alarm_sns_topic_arns = ["${data.terraform_remote_state.sns_region.arn}"]

  too_many_db_connections_threshold  = "${var.too_many_db_connections_threshold}"
  high_cpu_utilization_threshold     = "${var.high_cpu_utilization_threshold}"
  high_cpu_utilization_period        = "${var.high_cpu_utilization_period}"
  low_memory_available_threshold     = "${var.low_memory_available_threshold}"
  low_memory_available_period        = "${var.low_memory_available_period}"
  low_disk_space_available_threshold = "${var.low_disk_space_available_threshold}"
  low_disk_space_available_period    = "${var.low_disk_space_available_period}"
  enable_perf_alarms                 = "${var.enable_perf_alarms}"
}

# ---------------------------------------------------------------------------------------------------------------------
# PULL DATA FROM OTHER TERRAFORM TEMPLATES USING TERRAFORM REMOTE STATE
# These templates use Terraform remote state to access data from a number of other Terraform templates, all of which
# store their state in S3 buckets.
# ---------------------------------------------------------------------------------------------------------------------

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    region = "${var.terraform_state_aws_region}"
    bucket = "${var.terraform_state_s3_bucket}"
    key    = "${var.aws_region}/${var.vpc_name}/vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "bastion_host" {
  backend = "s3"

  config {
    region = "${var.terraform_state_aws_region}"
    bucket = "${var.terraform_state_s3_bucket}"
    key    = "${var.aws_region}/mgmt/bastion-host/terraform.tfstate"
  }
}

data "terraform_remote_state" "kms_master_key" {
  backend = "s3"

  config {
    region = "${var.terraform_state_aws_region}"
    bucket = "${var.terraform_state_s3_bucket}"
    key    = "${var.aws_region}/${var.vpc_name}/kms-master-key/terraform.tfstate"
  }
}

data "terraform_remote_state" "sns_region" {
  backend = "s3"

  config {
    region = "${var.terraform_state_aws_region}"
    bucket = "${var.terraform_state_s3_bucket}"
    key    = "${var.aws_region}/_global/sns-topics/terraform.tfstate"
  }
}
