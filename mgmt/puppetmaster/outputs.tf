output "dns_name" {
  value = "${aws_route53_record.bastion_host.fqdn}"
}

output "bastion_host_public_ip" {
  value = "${module.bastion.public_ip}"
}

output "bastion_host_private_ip" {
  value = "${module.bastion.private_ip}"
}

output "bastion_host_security_group_id" {
  value = "${module.bastion.security_group_id}"
}
