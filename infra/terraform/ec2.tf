# SSH key pair for the EC2 instances
#TODO Store key somewhere safe outside of repo

resource "aws_key_pair" "jenkins-controller" {
  key_name   = "jenkins-key"
  public_key = file("../../ssh/jenkins-key.pub")
}

# The AMIs created by packer
data "aws_ami" "jenkins-controller-ami" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = ["jenkins-controller-*"]
  }
}

data "aws_ami" "jenkins-agent-ami" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = ["jenkins-builder-docker-*"]
  }
}

# TODO Create IAM role for Jenkins controller

# EC2 instances for Jenkins controller

resource "aws_instance" "jenkins-controller" {
  ami           = data.aws_ami.jenkins-controller-ami.id
  instance_type = "t3.micro"

  iam_instance_profile = aws_iam_instance_profile.jenkins-controller.name
  key_name             = aws_key_pair.jenkins-controller.key_name

  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.jenkins-controller.id]

  //TODO Seperate EBS volume for Jenkins data
  //TODO Protect against accidental termination
  //TODO Add static IP
  tags = {
    Name = "TF Jenkins Controller"
  }
  lifecycle {
    ignore_changes = [ami]
  }
}

# EC2 launch template for Jenkins agents
resource "aws_launch_template" "jenkins-agent" {
  name_prefix   = "jenkins-agent-"
  image_id      = data.aws_ami.jenkins-agent-ami.id
  instance_type = "t3.small"
  key_name      = aws_key_pair.jenkins-controller.key_name
  iam_instance_profile {
    name = aws_iam_instance_profile.jenkins-agent.name
  }

  vpc_security_group_ids = [aws_security_group.jenkins-controller.id]
  #TODO set up new security group for agents

  block_device_mappings {
    device_name = "/dev/xvda"
    //TODO find out we use the disk or the one from the AMI
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }
}

# EC2 autoscaling group for Jenkins agents
resource "aws_autoscaling_group" "jenkins-agent" {
  name                      = "TF-jenkins-agent"
  max_size                  = 5
  min_size                  = 0
  desired_capacity          = 0
  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = false
  launch_template {
    id      = aws_launch_template.jenkins-agent.id
    version = "$Latest"
  }
  max_instance_lifetime = 86400

  vpc_zone_identifier = aws_subnet.public[*].id
  tag {
    key                 = "Name"
    value               = "TF Jenkins Agent"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [desired_capacity, min_size, max_size, protect_from_scale_in]
  }
}

# --- Outputs ---

output "jenkins-controller-public-ip" {
  value = aws_instance.jenkins-controller.public_ip
}
