# puppetmaster

This Terraform Module creates a single EC2 instance that is meant to serve as a Puppet master.
The resources that are created by these templates include:

1. An AMI to run on the puppetmaster
1. The EC2 instance
1. An Elastic IP Address (EIP).
1. IAM Role and IAM instance profile.
1. Security group.

Under the hood, this is all implemented using Terraform modules from the Gruntwork
[module-server](https://github.com/gruntwork-io/module-server) repo. If you don't have access to this repo, email
support@gruntwork.io.

## Known errors

When you run `terraform apply` on these templates the first time, you may see the following error:

```
* aws_iam_instance_profile.puppetmaster: diffs didn't match during apply. This is a bug with Terraform and should be reported as a GitHub Issue.
```

As the error implies, this is a Terraform bug, but fortunately, it's a harmless one related to the fact that AWS is
eventually consistent, and Terraform occasionally tries to use a recently-created resource that isn't yet available.
Just re-run `terraform apply` and the error should go away.
