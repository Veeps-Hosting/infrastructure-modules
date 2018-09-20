# Configure upstream provider
provider "aws" {
  region              = "${var.aws_region}"
  allowed_account_ids = ["${var.aws_account_id}"]
}

# Configure Terraform backend and version
terraform {
  backend "s3" {}
  required_version = "= 0.11.8"
}

# Specify "Cloud-init" or "User-data" to Bootstrap the instance
data "template_file" "user_data" {
  template = "${file("${path.module}/user-data/user-data.txt")}"
  vars {
    vpc_name       = "${data.terraform_remote_state.vpc.vpc_name}"
    log_group_name = "${var.name}"
  }
}

# Data source used above to determine vpc
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config {
    region = "${var.terraform_state_aws_region}"
    bucket = "${var.terraform_state_s3_bucket}"
    key    = "${var.aws_region}/${var.vpc_name}/vpc/terraform.tfstate"
  }
}

# Configure the Server
module "puppetmaster" {
  allow_ssh_from_cidr                   = false
  allow_ssh_from_security_group         = true
  allow_ssh_from_security_group_id      = "${data.terraform_remote_state.bastion_host.bastion_host_security_group_id}"
  ami                                   = "${var.ami}"
  attach_eip                            = false
  instance_type                         = "${var.instance_type}"
  name                                  = "${var.name}"
  keypair_name                          = "${var.keypair_name}"
  root_volume_size                      = "${var.root_volume_size}"
  source                                = "git::git@github.com:gruntwork-io/module-server.git//modules/single-server?ref=HEAD"
  subnet_id                             = "${var.subnet_id}"
  user_data                             = "${data.template_file.user_data.rendered}"
  tags                                  = {
    Role                                = "Puppetmaster"
  }
  vpc_id                                = "${var.vpc_id}"
}

# Configure the data source used above to determine the Bastion host dynamically
data "terraform_remote_state" "bastion_host" {
  backend = "s3"
  config {
    region = "${var.terraform_state_aws_region}"
    bucket = "${var.terraform_state_s3_bucket}"
    key    = "${var.aws_region}/${var.vpc_name}/bastion-host/terraform.tfstate"
  }
}

# Configure IAM permission to facilitate ssh_grunt
module "ssh_grunt_policies" {
  source                          = "git::git@github.com:gruntwork-io/module-security.git//modules/iam-policies?ref=HEAD"
  aws_account_id                  = "${var.aws_account_id}"
  iam_policy_should_require_mfa   = false
  trust_policy_should_require_mfa = false
}
resource "aws_iam_role_policy" "ssh_grunt_permissions" {
  name   = "ssh-grunt-permissions"
  policy = "${module.ssh_grunt_policies.ssh_grunt_permissions}"
  role   = "${module.puppetmaster.iam_role_id}"
}

#Configure CloudWatch Monitoring and IAM Permissions
module "cloudwatch_metrics" {
  source      = "git::git@github.com:gruntwork-io/module-aws-monitoring.git//modules/metrics/cloudwatch-custom-metrics-iam-policy?ref=HEAD"
  name_prefix = "${var.name}"
}
resource "aws_iam_policy_attachment" "attach_cloudwatch_metrics_policy" {
  name       = "attach-cloudwatch-metrics-policy"
  roles      = ["${module.puppetmaster.iam_role_id}"]
  policy_arn = "${module.cloudwatch_metrics.cloudwatch_metrics_policy_arn}"
}

# Configure CloudWatch log aggregation and IAM permission
module "cloudwatch_log_aggregation" {
  source      = "git::git@github.com:gruntwork-io/module-aws-monitoring.git//modules/logs/cloudwatch-log-aggregation-iam-policy?ref=HEAD"
  name_prefix = "${var.name}"
}
resource "aws_iam_policy_attachment" "attach_cloudwatch_log_aggregation_policy" {
  name       = "attach-cloudwatch-log-aggregation-policy"
  roles      = ["${module.puppetmaster.iam_role_id}"]
  policy_arn = "${module.cloudwatch_log_aggregation.cloudwatch_log_aggregation_policy_arn}"
}

# Configure CloudWatch Alarms in case CPU, Memory or Disk usage get too high
module "high_cpu_usage_alarms" {
  source               = "git::git@github.com:gruntwork-io/module-aws-monitoring.git//modules/alarms/ec2-cpu-alarms?ref=HEAD"
  instance_ids         = ["${module.puppetmaster.id}"]
  instance_count       = 1
  alarm_sns_topic_arns = ["${data.terraform_remote_state.sns_region.arn}"]
}
module "high_memory_usage_alarms" {
  source               = "git::git@github.com:gruntwork-io/module-aws-monitoring.git//modules/alarms/ec2-memory-alarms?ref=HEAD"
  instance_ids         = ["${module.puppetmaster.id}"]
  instance_count       = 1
  alarm_sns_topic_arns = ["${data.terraform_remote_state.sns_region.arn}"]
}
module "high_disk_usage_alarms" {
  source               = "git::git@github.com:gruntwork-io/module-aws-monitoring.git//modules/alarms/ec2-disk-alarms?ref=HEAD"
  instance_ids         = ["${module.puppetmaster.id}"]
  instance_count       = 1
  file_system          = "/dev/xvda1"
  mount_path           = "/"
  alarm_sns_topic_arns = ["${data.terraform_remote_state.sns_region.arn}"]
}

# Configure daily EC2 backups via Lambda with 2 week retention
module "puppetmaster_backup" {
  source                         = "git::git@github.com:gruntwork-io/module-ci.git//modules/ec2-backup?ref=HEAD"
  instance_name                  = "${module.puppetmaster.name}"
  backup_job_schedule_expression = "${var.backup_schedule_expression}"
  backup_job_alarm_period        = "${var.backup_job_alarm_period}"
  delete_older_than              = 15
  require_at_least               = 15
  cloudwatch_metric_name         = "${var.backup_job_metric_namespace}"
  cloudwatch_metric_namespace    = "${var.backup_job_metric_name}"
  alarm_sns_topic_arns           = ["${data.terraform_remote_state.sns_region.arn}"]
}

# Configure data source used for above SNS Alarm Topic ARNs
data "terraform_remote_state" "sns_region" {
  backend = "s3"
  config {
    region = "${var.terraform_state_aws_region}"
    bucket = "${var.terraform_state_s3_bucket}"
    key    = "${var.aws_region}/_global/sns-topics/terraform.tfstate"
  }
}

# Configure security group for Puppet port from Private ranges
resource "aws_security_group_rule" "puppet" {
  type              = "ingress"
  from_port         = 8140
  to_port           = 8140
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8","172.31.0.0/16"]
  security_group_id = "${module.puppetmaster.security_group_id}"
}

# Configure IAM to describe / read tags
resource "aws_iam_policy" "ec2_describetags" {
  name       = "${var.name}-ec2-describetags"
  roles      = ["${module.puppetmaster.iam_role_id}"]
  policy     = "${data.aws_iam_policy_document.ec2_describetags.json}"
}
data "aws_iam_policy_document" "ec2_describetags" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeTags"
    ]
    resources = ["*"]
  }
}

## Create a DNS entry for the server
#resource "aws_route53_record" "puppet" {
#  zone_id = ? Needs to be pushed via custom dhcp option set
#  name    = "puppet"
#  type    = "A"
#  ttl     = "300"
#  records = ["${module.puppetmaster.private_ip}"]
#}
