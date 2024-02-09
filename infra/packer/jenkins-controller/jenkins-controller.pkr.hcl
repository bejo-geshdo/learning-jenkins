packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[:]", "-")
}


source "amazon-ebs" "jenkins_controller" {
  ami_name = "jenkins-controller-${local.timestamp}"
  ami_description = "Jenkins Controller"

  source_ami_filter {
    filters = {
      # Full AMI NAME: "al2023-ami-2023.3.20240205.2-kernel-6.1-x86_64"
      name                = "al2023-ami-*-x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  instance_type = "t2.micro"
  region = "eu-central-1"
  ssh_username = "ec2-user"

  # TODO Add encryption, set IMDSv2 to true
}

build {
  sources = ["source.amazon-ebs.jenkins_controller"]

  provisioner "file" {
    source      = "install.sh"
    destination = "/home/ec2-user/install.sh"
  }

  provisioner "shell" {
    script = "install.sh"
  }
}
