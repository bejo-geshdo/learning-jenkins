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

  iam_instance_profile    = module.jenkin-contoller-iam.aws_iam_instance_profile_name
  key_name                = aws_key_pair.jenkins-controller.key_name
  disable_api_termination = true

  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.jenkins-controller.id, aws_security_group.github-webhook.id]

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

module "jenkins-builder-node" {
  source = "./modules/jenkin-builder"

  name                 = "tf-jenkins-agent-nodejs-"
  ami_name_filter      = "jenkins-builder-docker-*"
  key_name             = aws_key_pair.jenkins-controller.key_name
  security_groups      = [aws_security_group.jenkins-controller.id]
  subnet_ids           = [aws_subnet.public[0].id]
  iam_instance_profile = module.jenkin-agent-iam.aws_iam_instance_profile_name
}

module "jenkins-builder-packer" {
  source = "./modules/jenkin-builder"

  name                 = "tf-jenkins-agent-packer-"
  ami_name_filter      = "jenkins-builder-packer-*"
  key_name             = aws_key_pair.jenkins-controller.key_name
  security_groups      = [aws_security_group.jenkins-controller.id]
  subnet_ids           = [aws_subnet.public[0].id]
  iam_instance_profile = module.jenkins-agent-packer-iam.aws_iam_instance_profile_name
}

module "jenkins-builder-terraform" {
  source = "./modules/jenkin-builder"

  name                 = "tf-jenkins-agent-terraform-"
  ami_name_filter      = "jenkins-builder-terraform-*"
  key_name             = aws_key_pair.jenkins-controller.key_name
  security_groups      = [aws_security_group.jenkins-controller.id]
  subnet_ids           = [aws_subnet.public[0].id]
  iam_instance_profile = module.jenkins-agent-terraform-iam.aws_iam_instance_profile_name
}

# --- Outputs ---

output "jenkins-controller-public-ip" {
  value = aws_instance.jenkins-controller.public_ip
}
