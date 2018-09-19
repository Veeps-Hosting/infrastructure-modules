provider "aws" {
  region              = "${var.aws_region}"
  allowed_account_ids = ["${var.aws_account_id}"]
}
terraform {
  backend "s3" {}
  required_version = "= 0.11.8"
}
data "template_file" "user_data" {
  template = "${file("${path.module}/user-data/user-data.txt")}"
}
module "puppetmaster" {
  allow_ssh_from_cidr                   = false
  allow_ssh_from_security_group         = true
  allow_ssh_from_security_group_id      = "${data.terraform_remote_state.bastion_host.bastion_host_security_group_id}"
  ami                                   = "${var.ami}"
  attach_eip                            = false
  instance_type                         = "${var.instance_type}"
  name                                  = "${var.name}"
  keypair_name                          = "${var.keypair_name}"
  source                                = "git::git@github.com:gruntwork-io/module-server.git//modules/single-server?ref=v0.5.0"
  subnet_id                             = "${var.subnet_id}"
  user_data                             = "${data.template_file.user_data.rendered}"
  tags                                  = {
    Role                                = "Puppetmaster"
  }
  vpc_id                                = "${var.vpc_id}"
}
module "ssh_grunt_policies" {
  source = "git::git@github.com:gruntwork-io/module-security.git//modules/iam-policies?ref=HEAD"
  aws_account_id = "${var.aws_account_id}"
  iam_policy_should_require_mfa   = false
  trust_policy_should_require_mfa = false
}
resource "aws_iam_role_policy" "ssh_grunt_permissions" {
  name   = "ssh-grunt-permissions"
  policy = "${module.ssh_grunt_policies.ssh_grunt_permissions}"
  role   = "${module.puppetmaster.puppetmaster_iam_role_id}"

}

resource "aws_security_group_rule" "puppet" {
  type = "ingress"
  from_port = 8140
  to_port = 8140
  protocol = "tcp"
  cidr_blocks = ["10.0.0.0/8","172.31.0.0/16"]
  security_group_id = "${module.puppetmaster.security_group_id}"
}
data "terraform_remote_state" "bastion_host" {
  backend = "s3"
  config {
    region = "${var.terraform_state_aws_region}"
    bucket = "${var.terraform_state_s3_bucket}"
    key    = "${var.aws_region}/${var.vpc_name}/bastion-host/terraform.tfstate"
  }
}
