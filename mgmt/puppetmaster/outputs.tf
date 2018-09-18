output "dns_name" {
  value = "${aws_route53_record.puppetmaster.fqdn}"
}

output "puppetmaster_private_ip" {
  value = "${module.puppetmaster.private_ip}"
}

output "puppetmaster_security_group_id" {
  value = "${module.puppetmaster.security_group_id}"
}
