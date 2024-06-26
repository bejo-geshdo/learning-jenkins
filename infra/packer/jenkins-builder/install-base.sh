#!/bin/bash

sleep 30

# Set up swap space
#TODO Consider moving this to "userdata" in the launch template
echo "Setting up swap space"
sudo dd if=/dev/zero of=/swapfile bs=128M count=16
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo "/swapfile swap swap defaults 0 0" | sudo tee -a /etc/fstab

sudo yum update -y

# Install Java and Git
sudo yum install java-17-amazon-corretto -y
sudo yum install git -y