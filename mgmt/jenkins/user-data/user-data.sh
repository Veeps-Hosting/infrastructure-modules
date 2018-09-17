#!/bin/bash
#
# This script is meant to run in the User Data of Jenkins to:
#
# - Run the CloudWatch Logs Agent to send all data in syslog to CloudWatch
# - Mount a persistent EBS volume Jenkins can use for data storage
# - Start the Jenkins server
#
# Note that this script is intended to run on top of the AMI built from the Packer template packer/jenkins-ubuntu.json.

set -e

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

function attach_volume {
  local readonly aws_region="$1"
  local readonly volume_name_tag="$2"
  local readonly device_name="$3"
  local readonly mount_point="$4"
  local readonly owner="$5"

  mount-ebs-volume \
    --aws-region "$aws_region" \
    --volume-with-same-tag "$volume_name_tag" \
    --device-name "$device_name" \
    --mount-point "$mount_point" \
    --owner "$owner"
}

function start_cloudwatch_logs_agent {
  local readonly vpc_name="$1"
  local readonly log_group_name="$2"

  echo "Starting CloudWatch Logs Agent in VPC $vpc_name"
  /etc/user-data/cloudwatch-log-aggregation/run-cloudwatch-logs-agent.sh --vpc-name "$vpc_name" --log-group-name "$log_group_name" --extra-log-file jenkins=/var/log/jenkins/jenkins.log
}

function start_fail2ban {
  echo "Starting fail2ban"
  /etc/user-data/configure-fail2ban-cloudwatch/configure-fail2ban-cloudwatch.sh --cloudwatch-namespace Fail2Ban
}

function file_contains_text {
  local readonly text="$1"
  local readonly file="$2"
  grep -q "$text" "$file"
}

function file_exists {
  local readonly file="$1"
  [[ -f "$file" ]]
}

function append_text_in_file {
  local readonly text="$1"
  local readonly file="$2"

  echo -e "$text" | sudo tee -a "$file"
}

# Replace a line of text in a file. Only works for single-line replacements.
function replace_text_in_file {
  local readonly original_text_regex="$1"
  local readonly replacement_text="$2"
  local readonly file="$3"

  sudo sed -i "s|$original_text_regex|$replacement_text|" "$file"
}

function replace_or_append_in_file {
  local readonly original_text_regex="$1"
  local readonly replacement_text="$2"
  local readonly file="$3"

  if $(file_exists "$file") && $(file_contains_text "$original_text_regex" "$file"); then
    replace_text_in_file "$original_text_regex" "$replacement_text" "$file"
  else
    append_text_in_file "$replacement_text" "$file"
  fi
}

function start_jenkins {
  local readonly mount_point="$1"
  local readonly memory="$2"

  echo "Starting Jenkins with home directory $mount_point and memory $memory"

  run-jenkins \
    --memory "$memory" \
    --jenkins-home "$mount_point"
}

function start_server {
  local readonly aws_region="$1"
  local readonly volume_name_tag="$2"
  local readonly device_name="$3"
  local readonly mount_point="$4"
  local readonly owner="$5"
  local readonly memory="$6"
  local readonly vpc_name="$7"
  local readonly log_group_name="$8"

  start_cloudwatch_logs_agent "$vpc_name" "$log_group_name"

  start_fail2ban
  attach_volume "$aws_region" "$volume_name_tag" "$device_name" "$mount_point" "$owner"
  start_jenkins "$mount_point" "$memory"

  # Lock down the EC2 metadata endpoint so only the root and jenkins users can access it
  /usr/local/bin/ip-lockdown 169.254.169.254 root jenkins
}

# These variables are set via Terraform interpolation
start_server "${aws_region}" "${volume_name_tag}" "${device_name}" "${mount_point}" "${owner}" "${memory}" "${vpc_name}" "${log_group_name}"