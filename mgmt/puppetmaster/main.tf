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
  allow_ssh_from_security_group_id      = "${module.bastion.security_group_id}"
  allow_ssh_from_cidr                   = false
  allow_ssh_from_security_group         = true
  #allow_ssh_from_security_group_id      = "sg-0f62a35785364a066"
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
resource "aws_security_group_rule" "puppet" {
  type = "ingress"
  from_port = 8140
  to_port = 8140
  protocol = "tcp"
  cidr_blocks = ["10.0.0.0/8","172.31.0.0/16"]
  security_group_id = "${module.puppetmaster.security_group_id}"
}
