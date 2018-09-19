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
  allow_ssh_from_security_group_ids = ["${data.terraform_remote_state.bastion_host.bastion_host_security_group_id}"]
  ami                               = "${var.ami}"
  instance_type                     = "${var.instance_type}"
  name                              = "${var.name}"
  keypair_name                      = "${var.keypair_name}"
  source                            = "git::git@github.com:gruntwork-io/module-server.git//modules/single-server?ref=v0.5.0"
  subnet_id                         = "${var.subnet_id}"
  user_data                         = "${data.template_file.user_data.rendered}"
  tags                              = {
    Role                            = "Puppetmaster"
  }
  vpc_id                            = "${var.vpc_id}"
}
