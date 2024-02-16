#!/bin/bash

# Install docker
sudo yum install docker -y

sudo service docker start
# Allows ec2-user to run docker commands
sudo usermod -a -G docker ec2-user

curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-463.0.0-linux-x86_64.tar.gz
tar -xf google-cloud-cli-463.0.0-linux-x86_64.tar.gz
rm google-cloud-cli-463.0.0-linux-x86_64.tar.gz

./google-cloud-sdk/install.sh