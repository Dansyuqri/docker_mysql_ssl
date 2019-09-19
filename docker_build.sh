#!/bin/bash

CUSTOM_NAME=docker_mysql_ssl
CUSTOM_DIR=$HOME/docker_mysql_ssl/mysql
SWARM_IP=127.0.0.1

read -p "Enter the name for this custom image [empty for default - docker_mysql_ssl]: " -r
if [ ! -z "$REPLY" ]
then
    CUSTOM_NAME=$REPLY
fi
read -p "Enter the directory that you would like to use for storing MySQL files[empty for default - $HOME/docker_mysql_ssl/mysql]: " -r
if [ ! -z "$REPLY" ]
then
    CUSTOM_DIR=$REPLY
fi

mkdir -p $CUSTOM_DIR

# Build docker with custom sql scripts
docker build -t $CUSTOM_NAME .

# For this input, it has to be either one of the following:
# 1. IP address of an existing interfaces on your machine
# 2. default localhost IP address - 127.0.0.1
read -p "Enter the advertised address for initializing docker swarm [empty for default - 127.0.0.1]: " -r
if [ ! -z "$REPLY" ]
then
    SWARM_IP=$REPLY
fi

# Creates a swarm so that docker secret can be used locally
docker swarm init --advertise-addr $SWARM_IP

# Creates docker secret for use in your container
read -s -p "Please enter the desired root password: " -r
echo $REPLY | docker secret create db_root_password -

# Checks if you would like Docker to run without sudo command
read -p "Would you like to start the docker service? (y/n)" -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
docker service create \
	--network host \
	--name $CUSTOM_NAME \
	--secret db_root_password \
	--mount type=bind,source=$CUSTOM_DIR,destination=/var/lib/mysql \
	-e MYSQL_ROOT_PASSWORD_FILE="/run/secrets/db_root_password" \
	-e MYSQL_ROOT_HOST='%' \
	$CUSTOM_NAME \
	--ssl-ca=/etc/certs/ca.pem \
	--ssl-cert=/etc/certs/server-cert.pem \
	--ssl-key=/etc/certs/server-key.pem
fi
