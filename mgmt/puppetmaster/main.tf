# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# LAUNCH THE PUPPETMASTER
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
# LAUNCH THE PUPPETMASTER
# ---------------------------------------------------------------------------------------------------------------------

module "puppetmaster" {
  source = "git::git@github.com:gruntwork-io/module-server.git//modules/single-server?ref=v0.5.0"

  name          = "${var.name}"
  instance_type = "${var.instance_type}"
  ami           = "${var.ami}"
  user_data     = "${data.template_file.user_data.rendered}"
  tenancy       = "${var.tenancy}"

  vpc_id    = "${data.terraform_remote_state.vpc.vpc_id}"
  subnet_id = "${element(data.terraform_remote_state.vpc.private_subnet_ids, 0)}"

  dns_name    = "${var.dns_name}"
  dns_zone_id = "${var.dns_zone_id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL WILL RUN ON THE PUPPETMASTER DURING BOOT
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data" {
  template = "${file("${path.module}/user-data/user-data")}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ADD IAM POLICY THAT ALLOWS READING AND WRITING CLOUDWATCH METRICS
# ---------------------------------------------------------------------------------------------------------------------

module "cloudwatch_metrics" {
  source      = "git::git@github.com:gruntwork-io/module-aws-monitoring.git//modules/metrics/cloudwatch-custom-metrics-iam-policy?ref=v0.9.1"
  name_prefix = "${var.name}"
}

resource "aws_iam_policy_attachment" "attach_cloudwatch_metrics_policy" {
  name       = "attach-cloudwatch-metrics-policy"
  roles      = ["${module.puppetmaster.iam_role_id}"]
  policy_arn = "${module.cloudwatch_metrics.cloudwatch_metrics_policy_arn}"
}

# ------------------------------------------------------------------------------
# ADD IAM POLICY THAT ALLOWS CLOUDWATCH LOG AGGREGATION
# ------------------------------------------------------------------------------

module "cloudwatch_log_aggregation" {
  source      = "git::git@github.com:gruntwork-io/module-aws-monitoring.git//modules/logs/cloudwatch-log-aggregation-iam-policy?ref=v0.9.1"
  name_prefix = "${var.name}"
}

resource "aws_iam_policy_attachment" "attach_cloudwatch_log_aggregation_policy" {
  name       = "attach-cloudwatch-log-aggregation-policy"
  roles      = ["${module.puppetmaster.iam_role_id}"]
  policy_arn = "${module.cloudwatch_log_aggregation.cloudwatch_log_aggregation_policy_arn}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ADD CLOUDWATCH ALARMS THAT GO OFF IF THE PUPPETMASTER'S CPU, MEMORY, OR DISK USAGE GET TOO HIGH
# ---------------------------------------------------------------------------------------------------------------------

module "high_cpu_usage_alarms" {
  source               = "git::git@github.com:gruntwork-io/module-aws-monitoring.git//modules/alarms/ec2-cpu-alarms?ref=v0.9.1"
  instance_ids         = ["${module.puppetmaster.id}"]
  instance_count       = 1
  alarm_sns_topic_arns = ["${data.terraform_remote_state.sns_region.arn}"]
}

module "high_memory_usage_alarms" {
  source               = "git::git@github.com:gruntwork-io/module-aws-monitoring.git//modules/alarms/ec2-memory-alarms?ref=v0.9.1"
  instance_ids         = ["${module.puppetmaster.id}"]
  instance_count       = 1
  alarm_sns_topic_arns = ["${data.terraform_remote_state.sns_region.arn}"]
}

module "high_disk_usage_alarms" {
  source               = "git::git@github.com:gruntwork-io/module-aws-monitoring.git//modules/alarms/ec2-disk-alarms?ref=v0.9.1"
  instance_ids         = ["${module.puppetmaster.id}"]
  instance_count       = 1
  file_system          = "/dev/xvda1"
  mount_path           = "/"
  alarm_sns_topic_arns = ["${data.terraform_remote_state.sns_region.arn}"]
}

# ---------------------------------------------------------------------------------------------------------------------
# PULL MGMT VPC DATA FROM THE TERRAFORM REMOTE STATE
# These templates run on top of the VPCs created by the VPC templates, which store their Terraform state files in an S3
# bucket using remote state storage.
# ---------------------------------------------------------------------------------------------------------------------

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    region = "${var.terraform_state_aws_region}"
    bucket = "${var.terraform_state_s3_bucket}"
    key    = "${var.aws_region}/${var.vpc_name}/vpc/terraform.tfstate"
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

data "terraform_remote_state" "route53_public" {
  backend = "s3"

  config {
    region = "${var.terraform_state_aws_region}"
    bucket = "${var.terraform_state_s3_bucket}"
    key    = "_global/route53-public/terraform.tfstate"
  }
}
