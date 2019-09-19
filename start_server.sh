#!/bin/bash

CUSTOM_DIR=$HOME/docker_mysql_ssl
CUSTOM_NAME=docker_mysql_ssl

read -p "Enter the ABSOLUTE PATH to the directory for storing MySQL files[empty for default - $HOME/docker_mysql_ssl/mysql]: " -r
if [ ! -z "$REPLY" ]
then
    CUSTOM_DIR=$REPLY
fi
read -p "Enter the name for this custom image [empty for default - docker_mysql_ssl]: " -r
if [ ! -z "$REPLY" ]
then
    CUSTOM_NAME=$REPLY
fi

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
