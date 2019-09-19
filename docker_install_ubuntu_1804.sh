#!/bin/bash

# Update existing list of packages
sudo apt update

# Install packages required to allow apt install over HTTPS
sudo apt install apt-transport-https ca-certificates curl software-properties-common

# Get official GPG key from Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add Docker repo to apt sources
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"

# Update existing list of packages with newly added Docker repo
sudo apt update

# Install Docker-CE
sudo apt install docker-ce

# Checks if you would like Docker to run without sudo command
read -p "Would you like to run Docker without sudo command? (y/n)" -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
  sudo usermod -aG ${USER}
  su - ${USER}
fi

# Check if Docker service is running
sudo systemctl status docker