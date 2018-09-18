output "dns_name" {
  value = "${aws_route53_record.puppetmaster.fqdn}"
}

output "puppetmaster_public_ip" {
  value = "${module.bastion.public_ip}"
}

output "puppetmaster_private_ip" {
  value = "${module.bastion.private_ip}"
}

output "puppetmaster_security_group_id" {
  value = "${module.bastion.security_group_id}"
}
