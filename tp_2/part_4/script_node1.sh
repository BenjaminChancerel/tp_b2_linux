#!/bin/sh
#Benjam 
#03/09/2020

echo "192.168.2.22 node2.tp2.b2" >> /etc/hosts

#création des fichiers 
mkdir /srv
mkdir /srv/site1
touch /srv/site1/index.html
echo 'voici le site1 ya zebi' >> /srv/site1/index.html
mkdir /srv/site2
touch /srv/site2/index.html
echo 'oklm le site 2 en tn' >> /srv/site2/index.html

#donner les perms
chmod -R 755 /srv/site1
chown -R vagrant:vagrant /srv/site1

chmod -R 755 /srv/site2
chown -R vagrant:vagrant /srv/site2

firewall-cmd --zone=public --add-service=http
firewall-cmd --zone=public --add-service=https
firewall-cmd --reload

#config nginx
echo "worker_processes 1;
error_log nginx_error.log;
events {
    worker_connections 1024;
}
http {
     server {
       listen 80;
        server_name node1.tp1.b2;
        location / {
                return 301 /site1;
        }
        location /site1 {
                alias /srv/site1;
        }
        location /site2 {
                alias /srv/site2;
        }
}
server {
        listen 443 ssl;
        server_name node1.tp2.b2;
        ssl_certificate server.crt;
        ssl_certificate_key server.key;
        location / {
            return 301 /site1;
        }
        location /site1 {
            alias /srv/site1;
        }
        location /site2 {
            alias /srv/site2;
        }
        location ~ /netdata/(?<ndpath>.*) {
            proxy_redirect off;
            proxy_set_header Host \$host;
            proxy_set_header X-Forwarded-Host \$host;
            proxy_set_header X-Forwarded-Server \$host;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_http_version 1.1;
            proxy_pass_request_headers on;
            proxy_set_header Connection 'keep-alive';
            proxy_store off;
            proxy_pass http://netdata/\$ndpath\$is_args\$args;
            gzip on;
            gzip_proxied any;
            gzip_types *;
        }
    }
}" >> /etc/nginx/nginx.conf

#certificat
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout server.key -out server.crt -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=node1.tp2.b2"

mv server.crt /etc/nginx
mv server.key /etc/nginx

sudo systemctl start nginx

