# Aurora RDS Cluster

This Terraform Module creates an Aurora RDS cluster.

Under the hood, this is all implemented using the [aurora Terraform
module](https://github.com/gruntwork-io/module-data-storage/tree/master/modules/aurora) from the Gruntwork
[module-data-storage](https://github.com/gruntwork-io/module-data-storage) repo. If you don't have
access to this repo, email support@gruntwork.io.

## Core concepts

To understand core concepts like what is Aurora, connecting to the database, and scaling the database, see the
[Gruntwork Aurora Module Docs](https://github.com/gruntwork-io/module-data-storage/tree/master/modules/aurora).