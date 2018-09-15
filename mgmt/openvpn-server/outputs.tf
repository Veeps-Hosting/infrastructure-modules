output "autoscaling_group_id" {
  value = "${module.openvpn.autoscaling_group_id}"
}

output "dns_name" {
  value = "${element(concat(aws_route53_record.openvpn.*.fqdn, list("")), 0)}"
}

output "public_ip" {
  value = "${module.openvpn.public_ip}"
}

output "private_ip" {
  value = "${module.openvpn.private_ip}"
}

output "elastic_ip" {
  value = "${module.openvpn.elastic_ip}"
}

output "security_group_id" {
  value = "${module.openvpn.security_group_id}"
}

output "iam_role_id" {
  value = "${module.openvpn.iam_role_id}"
}

output "client_request_queue" {
  value = "${module.openvpn.client_request_queue}"
}

output "client_revocation_queue" {
  value = "${module.openvpn.client_revocation_queue}"
}

output "backup_bucket_name" {
  value = "${module.openvpn.backup_bucket_name}"
}

output "vpn_routes" {
  value = ["${data.template_file.vpn_routes.*.rendered}"]
}
