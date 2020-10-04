#!/bin/sh
#Benjam 
#03/09/2020

echo "192.168.2.22 node2.tp2.b2" >> /etc/hosts

#ajout de l'user "web"
useradd web -M -s /sbin/nologin

#Modifier les droits des certificats 
chmod 400 /etc/pki/tls/private/server.key
chown web:web /etc/pki/tls/private/server.key
chmod 444 /etc/pki/tls/certs/server.crt
chown web:web /etc/pki/tls/certs/server.crt

#ajouter lesservices http et https
firewall-cmd --zone=public --add-service=http
firewall-cmd --zone=public --add-service=https

#Configuration de NGINX
echo "worker_processes 1;
error_log /var/log/nginx/error.log;
events {
    worker_connections 1024;
}

pid /run/nginx.pid;
user web;

http {
    server {
        listen 80;
        server_name node1.tp2.b2;
        return 301 https://$host$request_uri;
    }

server {
        listen 443 ssl;
        server_name node1.tp2.b2;

        ssl_certificate /etc/pki/tls/certs/server.crt;
        ssl_certificate_key /etc/pki/tls/private/server.key;

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
}
" >> /etc/nginx/nginx.conf

# création des dossiers avec les fichiers 
mkdir /srv
mkdir /srv/site1
touch /srv/site1/index.html
chown web:web /srv/site1/index.html
chmod 550 /srv/site1
chmod 440 /srv/site1/index.html
echo 'site 1' | tee /srv/site1/index.html

mkdir /srv/site2
touch /srv/site2/index.html
chown web:web /srv/site2/index.html
chmod 550 /srv/site2
chmod 440 /srv/site2/index.html
echo 'site 2' | tee /srv/site2/index.html

#certificat 
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout server.key -out server.crt -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=node1.tp2.b2"

mv server.crt /etc/nginx
mv server.key /etc/nginx

systemctl start nginx

# installation netdata
bash <(curl -Ss https://my-netdata.io/kickstart.sh) --dont-wait

sudo firewall-cmd --add-port=19999/tcp --permanent

sudo firewall-cmd --reload
