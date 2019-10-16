#!/bin/bash

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

# run jenkins-slave
jenkins-slave