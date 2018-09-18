output "id" {
  value = "${aws_instance.instance.id}"
}
output "fqdn" {
  value = "${join(",", aws_route53_record.instance.*.fqdn)}"
}
output "instance_ip" {
  value = "${aws_instance.instance.public_ip}"
}
