output "cluster_id" {
  value = "${module.database.cluster_id}"
}

output "cluster_arn" {
  value = "${module.database.cluster_arn}"
}

output "primary_endpoint" {
  value = "${module.database.cluster_endpoint}"
}

output "instance_endpoints" {
  value = "${module.database.instance_endpoints}"
}

output "port" {
  value = "${module.database.port}"
}
