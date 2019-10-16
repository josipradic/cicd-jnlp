#!/bin/bash

SERVICE=$(echo $DOCKER_HOST | cut -d'/' -f3 | cut -d':' -f1)
PORT=$(echo $DOCKER_HOST | sed -e 's,^.*:,:,g' -e 's,.*:\([0-9]*\).*,\1,g' -e 's,[^0-9],,g')

# let's wait for docker host to be ready before continue
if [[ ! -e $SERVICE && ! -e $PORT ]]; then

    # number of retries
    RETRIES=3
    RETRY=0

    until nc -z $SERVICE $PORT || [ $RETRY -eq $RETRIES ]; do
        echo "Waiting for docker host to connect ("$(( ++RETRY ))"/$RETRIES): $DOCKER_HOST"
        sleep 1
    done

    if [ $RETRY == $RETRIES ]; then
        echo "Failed to connect."
        exit 1
    else
        # we managed to successfully connect to docker host, which means that docker dind placed certificates
        # convert certificates from .pem to .crt
        openssl x509 -outform der \
            -in /usr/local/share/ca-certificates/ca.pem \
            -out /usr/local/share/ca-certificates/ca.crt
        openssl x509 -outform der \
            -in /usr/local/share/ca-certificates/cert.pem \
            -out /usr/local/share/ca-certificates/client.crt
        openssl x509 -outform der \
            -in /usr/local/share/ca-certificates/key.pem \
            -out /usr/local/share/ca-certificates/client.key

        # update certificates
        sudo update-ca-certificates
    fi
fi

# run jenkins-slave
jenkins-slave