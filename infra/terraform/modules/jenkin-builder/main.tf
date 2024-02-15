# AMI
data "aws_ami" "jenkins-agent-ami" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }
}

# EC2 launch template for Jenkins agents
resource "aws_launch_template" "jenkins-agent" {
  image_id = data.aws_ami.jenkins-agent-ami.id
  key_name = var.key_name
  iam_instance_profile {
    name = var.iam_instance_profile
  }

  vpc_security_group_ids = var.security_groups

  #TODO be able to add more than one volume
  dynamic "block_device_mappings" {
    for_each = var.volume_size != 0 ? [1] : []
    content {
      device_name = "/dev/xvda"
      ebs {
        volume_size           = var.volume_size
        volume_type           = "gp3"
        delete_on_termination = true
        encrypted             = true
      }
    }
  }

  user_data = var.user_data_b64
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

  vpc_zone_identifier = var.subnet_ids
  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }

  lifecycle {
    #TODO findout what else i need to ignore
    ignore_changes = [desired_capacity, min_size, max_size, protect_from_scale_in]
  }
}
