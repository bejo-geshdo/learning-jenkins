# SSH key pair for the EC2 instances
#TODO Store key somewhere safe outside of repo

/*
resource "aws_key_pair" "jenkins-controller" {
  key_name   = "jenkins-key"
  public_key = "../../keys/jenkins-key.pub"
}
*/

# The AMI created by packer
data "aws_ami" "jenkins-controller-ami" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = ["jenkins-controller-*"]
  }
}

# EC2 instances for Jenkins controller

resource "aws_instance" "jenkins-controller" {
  ami           = data.aws_ami.jenkins-controller-ami.id
  instance_type = "t3.micro"
  //key_name      = aws_key_pair.jenkins-controller.key_name
  subnet_id = aws_subnet.public[0].id
  #vpc_security_group_ids = [aws_security_group.jenkins-controller.id]
  tags = {
    Name = "TF Jenkins Controller"
  }

  vpc_security_group_ids = [aws_security_group.jenkins-controller.id]

  //TODO Seperate EBS volume for Jenkins data
  //TODO Protect against accidental termination
  //TODO Add static IP
}

# EC2 launch template for Jenkins agents
# EC2 autoscaling group for Jenkins agents
# How do we let Jenkins controll the ASG without Terraform trying to manage it