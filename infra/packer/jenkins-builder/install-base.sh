#!/bin/bash

sleep 30

sudo yum update -y

# Install Java and Git
sudo yum install java-17-amazon-corretto -y
sudo yum install git -y

# Install Node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
. ~/.nvm/nvm.sh
nvm install --lts

# Install docker
sudo yum install docker -y

sudo service docker start
# Allows ec2-user to run docker commands
sudo usermod -a -G docker ec2-user