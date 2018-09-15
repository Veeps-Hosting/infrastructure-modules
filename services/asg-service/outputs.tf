output "asg_name" {
  value = "${module.asg.asg_name}"
}

output "fully_qualified_domain_name" {
  value = "${element(concat(aws_route53_record.service.*.fqdn, list("")), 0)}"
}

output "alb_dns_name" {
  value = "${data.terraform_remote_state.alb.alb_dns_name}"
}

output "alb_name" {
  value = "${data.terraform_remote_state.alb.alb_name}"
}
