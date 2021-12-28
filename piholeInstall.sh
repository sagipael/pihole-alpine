#!/bin/bash

release="$(cat /etc/alpine-release  | awk -F. '{print $1"."$2}')"
echo "
http://dl-cdn.alpinelinux.org/alpine/v${release}/main
http://dl-cdn.alpinelinux.org/alpine/v{release}/community
" > /etc/apk/repositories


apk add git bash curl

## clean
rm -f -r /etc/.pihole* /opt/pihole* /etc/pihole* /usr/bin/pihole-FTL  /etc/dnsmasq*
delgroup pihole 2> /dev/null
deluser pihole 2> /dev/null
rm -f -r /var/www/html/*



#git clone -b my-branch git@github.com:user/myproject.git
#git clone -b dev https://github.com/sagipael/pihole-alpine.git
git clone -b dev ssh://git@github.com/sagipael/pihole-alpine.git
#curl ftp://172.20.120.101/pihole/basic-install.sh | bash


exit 


curl ftp://172.20.120.101/pihole/pihole_install.sh | bash


preInstall   # sagi