# Jenkins

This Terraform Module can be used to deploy [Jenkins](https://jenkins.io/), an open source build automation server.

The resources that are created by this module include:

- An ASG to run Jenkins (using the [Gruntwork single-server
  module](https://github.com/gruntwork-io/module-server/tree/master/modules/single-server)).
- An EBS volume for Jenkins that persists between redeploys (using the [Gruntwork persistent-ebs-volume
  module](https://github.com/gruntwork-io/module-server/tree/master/modules/persistent-ebs-volume)).
- A lambda job to periodically take a snapshot of the EBS volume (using the [Gruntwork ec2-backup
  module](https://github.com/gruntwork-io/module-ci/tree/master/modules/ec2-backup)).
- A CloudWatch alarm that goes off if a backup job fails to run (using the [Gruntwork ec2-backup
  module](https://github.com/gruntwork-io/module-ci/tree/master/modules/ec2-backup)).
- The [CloudWatch Logs
  Agent](http://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/QuickStartEC2Instance.html) to send all
  logs in syslog and in the [Jenkins app log](https://wiki.jenkins-ci.org/display/JENKINS/Logging) to [CloudWatch
  Logs](http://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/WhatIsCloudWatchLogs.html) (using the
  [Gruntwork cloudwatch-log-aggregation-scripts
  module](https://github.com/gruntwork-io/module-aws-monitoring/tree/master/modules/logs/cloudwatch-log-aggregation-scripts)).
- Custom metrics that are not available by default in CloudWatch, including memory and disk usage (using the [Gruntwork
  cloudwatch-memory-disk-metrics-scripts
  module](https://github.com/gruntwork-io/module-aws-monitoring/tree/master/modules/metrics/cloudwatch-memory-disk-metrics-scripts)).
- Automatic log rotation and rate limiting (using the [Gruntwork syslog
  module](https://github.com/gruntwork-io/module-aws-monitoring/tree/master/modules/logs/syslog)).
- SSH access via IAM user accounts and public keys (using the [Gruntwork ssh-grunt
  module](https://github.com/gruntwork-io/module-security/tree/master/modules/ssh-grunt)).
- Automatic security updates for the server (using the [Gruntwork auto-update
  module](https://github.com/gruntwork-io/module-security/tree/master/modules/auto-update)).
- An ALB to route traffic to Jenkins
- A Route 53 DNS A record pointing at the ALB

If you don't have access to any of the Gruntwork modules, email support@gruntwork.io.

## How do you use this module?

To use this module, you need to:

1. Build the AMI
1. Use the module in your Terraform code

#### Build the AMI

The Jenkins server should run the AMI built using the [Packer](https://www.packer.io/) template in
`packer/jenkins-ubuntu.json`.

To build the AMI from the Packer template:

1. Install [Packer](https://www.packer.io/).
1. Set your AWS credentials as the environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.
1. Set your [GitHub access token](https://help.github.com/articles/creating-an-access-token-for-command-line-use/)
   as the environment variable `GITHUB_OAUTH_TOKEN`. Your GitHub account must have access to the Gruntwork GitHub
   repos mentioned in `packer/jenkins-ubuntu.json`; if you don't have access to those, email support@gruntwork.io.
1. Run `packer build jenkins-ubuntu.json`.
1. When the build completes, it'll output the id of the new AMI.

#### Use the module in your Terraform code

* See the [root README](/README.md) for instructions on using Terraform modules.
* See [vars.tf](./vars.tf) for all the variables you can set on this module.

## How is Jenkins configured?

#### The JENKINS_HOME directory

These templates mount the [JENKINS_HOME directory](https://wiki.jenkins-ci.org/display/JENKINS/Administering+Jenkins)
on a separate, persistent EBS volume at path `/jenkins`. Unlike a root volume on an EC2 Instance, this EBS volume will
persist between redeploys so you don't lose all your data each time you push out new code.

#### Upgrades

If you want to upgrade the Jenkins version, your best option is to update the `jenkins_version` variable in this Packer
template. If you use the Jenkins UI to do upgrades, you will lose that upgrade the next time you deploy a new AMI. A
Jenkins upgrade installs a new war file for Jenkins onto the root volume. The `JENKINS_HOME` directory should remain
unchanged and continue working with the new version.

#### Plugins

When you first [install Jenkins](https://jenkins.io/download/), it walks you through a Setup Wizard. As part of that
process, we recommend using the standard set of plugins recommended by the Setup Wizard. On top of that, we also
typically install two other useful plugins using the plugins UI:

1. [Parameterized Trigger Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Parameterized+Trigger+Plugin). This
   allows us to run one build and then use the output of that build to fill in the parameters and trigger a
   [parameterized build](https://wiki.jenkins-ci.org/display/JENKINS/Parameterized+Build).
1. [SSH Agent Plugin](https://wiki.jenkins-ci.org/display/JENKINS/SSH+Agent+Plugin). This allows us to load SSH
   credentials into SSH Agent so that anything in your build that depends on SSH authentication (e.g. Terraform modules
   pulled down via SSH auth) will "just work".

#### ALB

We have deployed Jenkins with an [Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html) 
in front of it for a few reasons:

1. It provides SSL termination.
1. It can use SSL certificates from the [AWS Certificate Manager](https://aws.amazon.com/certificate-manager/). These
   certificates are free and auto-renew, which makes maintenance much easier.
1. It allows us to run Jenkins itself in a private subnet. Given all the different types of code a developer is likely
   to run on Jenkins, it will be hard to lock it down fully, so running it in a private subnet offers a little more
   protection from dumb mistakes (e.g. opening up a port).

#### IAM permissions

In order for Jenkins to be able to do automatic deployment by running Terraform, we have given it IAM permissions to
access a large number of AWS APIs. This means Jenkins is a highly trusted actor and we need to be extra careful in how
we manage and secure it.

## Core concepts

For more info on what is Jenkins, how to configure it, and how to use it to set up continuous integration and
continuous delivery, see the [Jenkins documentation](https://jenkins.io/doc/).
For info on finding the Jenkins logs in CloudWatch, check out the [cloudwatch-log-aggregation-scripts
documentation](https://github.com/gruntwork-io/module-aws-monitoring/tree/master/modules/logs/cloudwatch-log-aggregation-scripts).
For info on viewing the custom metrics in CloudWatch, check out the [cloudwatch-memory-disk-metrics-scripts
documentation](https://github.com/gruntwork-io/module-aws-monitoring/tree/master/modules/metrics/cloudwatch-memory-disk-metrics-scripts).
