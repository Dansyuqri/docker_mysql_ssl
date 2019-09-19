#!/bin/bash

docker run \
    -it \
    --network host \
    --rm mysql:5.7 \
    mysql -u root -h 0.0.0.0 -P 3306 -p 	
    --ssl-ca=certs/ca.pem \
	--ssl-cert=certs/server-cert.pem \
	--ssl-key=certs/server-key.pem
