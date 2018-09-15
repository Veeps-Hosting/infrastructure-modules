#!/bin/bash
# Install dependencies used by Jenkins builds, such as Terraform, Terragrunt, Packer, and Docker

set -e

readonly TERRAFORM_VERSION="0.11.7"
readonly TERRAGRUNT_VERSION="v0.16.7"
readonly PACKER_VERSION="1.0.0"
readonly DOCKER_VERSION="17.03.1~ce-0~ubuntu-xenial"
readonly JENKINS_USER="jenkins"

function install_terraform {
  local readonly version="$1"

  echo "Installing Terraform $version"
  wget "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_linux_amd64.zip"
  unzip "terraform_${version}_linux_amd64.zip"
  sudo cp terraform /usr/local/bin/terraform
  sudo chmod a+x /usr/local/bin/terraform
}

function install_terragrunt {
  local readonly version="$1"

  echo "Installing Terragrunt $version"
  wget "https://github.com/gruntwork-io/terragrunt/releases/download/$version/terragrunt_linux_amd64"
  sudo cp terragrunt_linux_amd64 /usr/local/bin/terragrunt
  sudo chmod a+x /usr/local/bin/terragrunt
}

function install_packer {
  local readonly version="$1"

  echo "Installing Packer $version"
  wget "https://releases.hashicorp.com/packer/${version}/packer_${version}_linux_amd64.zip"
  unzip "packer_${version}_linux_amd64.zip"
  sudo cp packer /usr/local/bin/packer
  sudo chmod a+x /usr/local/bin/packer
}

# Based on: https://docs.docker.com/engine/installation/linux/ubuntu/#install-using-the-repository
function install_docker {
  local readonly version="$1"

  echo "Installing Docker $version"

  sudo apt-get install -y linux-image-extra-virtual
  sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt-get update
  sudo apt-get install -y docker-ce="$version"

  # This allows us to run Docker without sudo: http://askubuntu.com/a/477554
  echo "Adding user $JENKINS_USER to Docker group"
  sudo gpasswd -a "$JENKINS_USER" docker
}

function install_git {
  echo "Installing Git"
  sudo apt-get install -y git
}

function install {
  install_terraform "$TERRAFORM_VERSION"
  install_terragrunt "$TERRAGRUNT_VERSION"
  install_packer "$PACKER_VERSION"
  install_docker "$DOCKER_VERSION"
  install_git
}

install