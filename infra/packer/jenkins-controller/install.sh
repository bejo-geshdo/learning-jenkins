#!/bin/bash

sleep 30

sudo yum update -y
sudo yum install -y wget

# Install Java and Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade

# Add required dependencies for the jenkins package
sudo yum install java-17-amazon-corretto -y
sudo yum install jenkins -y

# Change jenkins temp dir
echo 'JENKINS_JAVA_OPTIONS="-Djava.awt.headless=true -Djava.io.tmpdir=/home/ec2-user/tmp"' | sudo tee -a /etc/sysconfig/jenkins


sudo systemctl enable jenkins
sudo systemctl start jenkins

# Echo Jenkins password
echo "Jenkins password: "
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# Set up password????

#TODO Look into if we should set SELinux to "enforcing"