#!/bin/bash

# Generate a Diffie-Hellman keys
# openssl dhparam -out /etc/nginx/dhparam.pem 2048

# Get Lets Encrypt SSL certificate using certbot
certbot certonly --cert-name {{ domain_name }} -d {{ subdomain_name }} --email {{ email }} --agree-tos -n --force-renewal || exit 1

if [ $? -eq 0 ] ; then 
    echo "SSL certificate successfully obtained"
else
    echo "SSL certificate could not be obtained"
    exit 1
fi