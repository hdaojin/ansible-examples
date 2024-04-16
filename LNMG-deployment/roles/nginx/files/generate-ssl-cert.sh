#!/bin/bash

# Generate a Diffie-Hellman keys
# openssl dhparam -out /etc/nginx/dhparam.pem 2048

# argument loading from yml
# domain_name="example.com"
# subdomain_name="www.example.com, *.example.com"
# email="user@example.com"

domain_name="itnsa.cn"
subdomain_name="www.itnsa.cn"
email="hdaojin@hotmail.com"

# Install certbot using snapd
sudo apt install -y snapd
sudo snap install core
sudo snap refresh core
sudo apt remove -y certbot
sudo snap install --classic certbot
[ -L /usr/bin/certbot ] || sudo ln -s /snap/bin/certbot /usr/bin/certbot
echo -e "$echo_success Installing system packages successfully"

# Get Lets Encrypt SSL certificate using certbot
sudo certbot certonly --cert-name $domain_name -d $domain_name -d $subdomain_name --email $email --agree-tos --nginx -n --force-renewal || exit 1

if [ $? -eq 0 ] ; then 
    echo "SSL certificate successfully obtained"
else
    echo "SSL certificate could not be obtained"
    exit 1
fi