# Docker MySQL SSL Setup
This document serves as a guide for setting up SSL with the [official MySQL Docker image](https://hub.docker.com/_/mysql). 

## Contents

1. [Getting Started](#getting-started)
2. [Directory tree](#directory-tree) 
3. [Generating Certificates and Keys](#generating-certificates-and-keys)
4. [Creating the Dockerfile with certificates and keys](#creating-the-dockerfile-with-certificates-and-keys)
5. [Building the custom image](#building-the-custom-image)
6. [Starting your container with SSL enabled](#starting-your-container-with-ssl-enabled)

## Getting Started
Clone this repository
```bash
$ git clone git@github.com:Dansyuqri/docker_mysql_ssl.git
```

Work in the directory
```bash
$ cd docker_mysql_ssl
```

## Directory tree
The following shows the directory structure. The certs and keys are to-be-generated in the `certs/` folder using the `gen_certs_rsa.sh` script. However, the other files should be placed accordingly.
```bash
.
├── certs
│   ├── gen_certs_rsa.sh
├── docker_build.sh
├── Dockerfile
├── docker_install_ubuntu_1804.sh
├── docker_mysql_ssl_setup.md
├── start_client.sh
└── start_server.sh
```

## Generating Certificates and Keys
Simply run the `gen_certs_rsa.sh` script in the certs folder. 

```bash
$ bash gen_certs_rsa.sh
```

You will be prompted for some inputs such as country code, state, location, block size and days before expiration of certificates. You should check that you get 8 files from this script. Place this script in the `certs/` folder.

**Credits:** Some parts in this segment was referenced from [Connect with SSL to MySQL in Docker container](https://techsparx.com/software-development/docker/damp/mysql-ssl-connection.html).

## Creating the Dockerfile with certificates and keys
The next step would be to create a Dockerfile that will allow you to build the custom MySQL image containing the necessary certs and keys. Do note that the default image already contains certs and keys in the `/var/lib/mysql` folder. We would want to copy existing certs and keys into the image. You may use the existing Dockerfile or create a new one with your own needs. You may refer to the following snippet for creating your own Dockerfile.

**Note:** Remember to create the Dockerfile outside of the `certs/` folder.

```dockerfile
# Use the official docker image for mysql tag 5.7
FROM mysql:5.7

# Create a directory called certs in the image
RUN mkdir -p /etc/certs
# Copy all certs and keys into the newly created /etc/certs
COPY certs/*.pem /etc/certs/
# IMPORTANT: chown the /etc/certs folder so that it belongs to user:group mysql:mysql
RUN chown -R mysql:mysql /etc/certs

# Copy any other start up scripts if you need to
# COPY example_start.sql /docker-entrypoint-initdb.d/
```

## Building the custom image
The next step is to run the `docker_build.sh`. 

```bash
$ bash docker_build.sh
```

You will be prompted for inputs. Just follow through the prompts and enter accordingly. 

**NOTE:** Do note to enter the **absolute path** to the directory for your MySQL files.

This script essentially builds the custom image from the Dockerfile created in the previous step. It also initializes a docker swarm which is then used to create a docker secret. The docker secret `db_root_password` stores the root password of your database. At the end of building the image, you will be prompted if you want to start the docker service immediately. You can do so or enter `n` when prompted. You can also start the docker service via the `start_server.sh` script, as shown in the next segment.

## Starting your container with SSL enabled
Simply run the `start_server.sh` and a docker service will be started. 

```bash
$ bash start_server.sh
```

You will be prompted for inputs similar to the  `docker_build.sh` script. Do note to enter the **absolute path** to the directory for your MySQL files.

This service will use the certificates and keys created in previous steps to establish an SSL connection with incoming client connections. Do note that clients without corresponding client certs and keys will connect without encryption. 

To test the connection to your newly created MySQL server, run the `start_client.sh` script.

You can then run the `status` command like so:

```bash
mysql > status

--------------
mysql  Ver 14.14 Distrib 5.7.27, for Linux (x86_64) using  EditLine wrapper

Connection id:          8
Current database:
Current user:           root@127.0.0.1
SSL:                    Cipher in use is DHE-RSA-AES256-SHA
Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server version:         5.7.27 MySQL Community Server (GPL)
Protocol version:       10
Connection:             0.0.0.0 via TCP/IP
Server characterset:    latin1
Db     characterset:    latin1
Client characterset:    latin1
Conn.  characterset:    latin1
TCP port:               3306
Uptime:                 7 min 6 sec

Threads: 1  Questions: 26  Slow queries: 0  Opens: 106  Flush tables: 1  Open tables: 99  Queries per second avg: 0.061

```

Note the line `SSL: ...`. If there are no ciphers being shown, i.e. `SSL: Not in use`, that means that your connection is not secure.

## LICENSE

[MIT](https://github.com/Dansyuqri/docker_mysql_ssl/blob/master/LICENSE)
