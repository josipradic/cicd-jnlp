#!/bin/bash

# parse DOCKER_HOST var and get service and ports for netcat command
SERVICE=$(echo $DOCKER_HOST | cut -d'/' -f3 | cut -d':' -f1)
PORT=$(echo $DOCKER_HOST | sed -e 's,^.*:,:,g' -e 's,.*:\([0-9]*\).*,\1,g' -e 's,[^0-9],,g')

# let's wait for docker host to be ready before continue
if [[ ! -e $SERVICE && ! -e $PORT && ! -e $CERT_DIR ]]; then

    # number of retries
    RETRIES=50
    RETRY=0
    until nc -z $SERVICE $PORT || [ $RETRY -eq $RETRIES ]; do
        echo "Waiting for docker host to connect ("$(( ++RETRY ))"/$RETRIES): $DOCKER_HOST"
        sleep 1
    done

    if [ $RETRY == $RETRIES ]; then
        echo "Failed to connect to: $DOCKER_HOST"
        exit 1
    else
        # if docker dind successfully shared certificates on the shared volume
        if [ -d $CERT_DIR ]; then
            # convert certificates from .pem to .crt
            openssl x509 -outform der \
                -in $CERT_DIR/ca.pem \
                -out $CERT_DIR/ca.crt
            openssl x509 -outform der \
                -in $CERT_DIR/cert.pem \
                -out $CERT_DIR/client.crt
            openssl x509 -outform der \
                -in $CERT_DIR/key.pem \
                -out $CERT_DIR/client.key

            # update certificates
            sudo update-ca-certificates
        else
            echo "Coudln't update CA certificates because the directory is empty."
        fi
    fi
fi

# run jenkins-slave
jenkins-slave