# TP:1 Déploiement classique 
(oééé lE bOsS Ti é eN LakOstE Tn oU kOi ?)

(si t'as oublié : l'ip de la vm est 192.168.1.6 parce que j'ai eu un problème)

## 0 prérequis 

### Partitionnement

La : on a ajouté les disques en PV (physical Volume) dans lvm 

carré

```
[cbenjamin@localhost ~]$ lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0    8G  0 disk
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0    7G  0 part
  ├─centos-root 253:0    0  6,2G  0 lvm  /
  └─centos-swap 253:1    0  820M  0 lvm  [SWAP]
sdb               8:16   0    2G  0 disk
sdc               8:32   0    3G  0 disk
sr0              11:0    1 1024M  0 rom
[cbenjamin@localhost ~]$ sudo pvcreate /dev/sdb
[sudo] Mot de passe de cbenjamin : 
  Physical volume "/dev/sdb" successfully created.
[cbenjamin@localhost ~]$ sudo pvcreate /dev/sdc
  Physical volume "/dev/sdc" successfully created.
[cbenjamin@localhost ~]$
```
Et la on fait le volume group "data" :

```
[cbenjamin@localhost ~]$ sudo vgs
  VG     #PV #LV #SN Attr   VSize  VFree
  centos   1   2   0 wz--n- <7,00g    0
  data     2   0   0 wz--n-  4,99g 4,99g
[cbenjamin@localhost ~]$
```


et la ducoup on a fait les Logical Volumes LV :

```
cbenjamin@localhost ~]$ sudo lvs
  LV    VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root  centos -wi-ao----  <6,20g
  swap  centos -wi-ao---- 820,00m
  phil1 data   -wi-a-----   2,00g
  phil2 data   -wi-a-----   2,99g
[cbenjamin@localhost ~]$
```

maintenant on va les formater 

Pour ``Phil1`` :

```
[cbenjamin@localhost ~]$ sudo kfs -t ext4 /dev/data/phil1
mke2fs 1.42.9 (28-Dec-2013)
Étiquette de système de fichiers=
Type de système d'exploitation : Linux
Taille de bloc=4096 (log=2)
Taille de fragment=4096 (log=2)
« Stride » = 0 blocs, « Stripe width » = 0 blocs
131072 i-noeuds, 524288 blocs
26214 blocs (5.00%) réservés pour le super utilisateur
Premier bloc de données=0
Nombre maximum de blocs du système de fichiers=536870912
16 groupes de blocs
32768 blocs par groupe, 32768 fragments par groupe
8192 i-noeuds par groupe
Superblocs de secours stockés sur les blocs :
        32768, 98304, 163840, 229376, 294912

Allocation des tables de groupe : complété
Écriture des tables d'i-noeuds : complété
Création du journal (16384 blocs) : complété
Écriture des superblocs et de l'information de comptabilité du système de
fichiers : complété

[cbenjamin@localhost ~]$
```

Pour ``Phil2`` :

```
[cbenjamin@localhost ~]$ sudo mkfs -t ext4 /dev/data/phil2
mke2fs 1.42.9 (28-Dec-2013)
Étiquette de système de fichiers=
Type de système d'exploitation : Linux
Taille de bloc=4096 (log=2)
Taille de fragment=4096 (log=2)
« Stride » = 0 blocs, « Stripe width » = 0 blocs
196224 i-noeuds, 784384 blocs
39219 blocs (5.00%) réservés pour le super utilisateur
Premier bloc de données=0
Nombre maximum de blocs du système de fichiers=803209216
24 groupes de blocs
32768 blocs par groupe, 32768 fragments par groupe
8176 i-noeuds par groupe
Superblocs de secours stockés sur les blocs :
        32768, 98304, 163840, 229376, 294912

Allocation des tables de groupe : complété
Écriture des tables d'i-noeuds : complété
Création du journal (16384 blocs) : complété
Écriture des superblocs et de l'information de comptabilité du système de
fichiers : complété

[cbenjamin@localhost ~]$
```

On les montes en l'air (telle des LOPEZ)

```
[cbenjamin@localhost ~]$ df -h
Sys. de fichiers        Taille Utilisé Dispo Uti% Monté sur
devtmpfs                  484M       0  484M   0% /dev
tmpfs                     496M       0  496M   0% /dev/shm
tmpfs                     496M    6,9M  489M   2% /run
tmpfs                     496M       0  496M   0% /sys/fs/cgroup
/dev/mapper/centos-root   6,2G    1,3G  5,0G  21% /
/dev/sda1                1014M    167M  848M  17% /boot
tmpfs                     100M       0  100M   0% /run/user/1000
tmpfs                     100M       0  100M   0% /run/user/0
/dev/mapper/data-phil1    2,0G    6,0M  1,8G   1% /srv/site1
/dev/mapper/data-phil2    2,9G    9,0M  2,8G   1% /srv/site2
[cbenjamin@localhost ~]$                          
```

Et voila : 

```
[cbenjamin@localhost ~]$ sudo mount -av
/                         : ignoré
/boot                     : déjà monté
swap                      : ignoré
/srv/site1                : déjà monté
/srv/site2                : déjà monté
[cbenjamin@localhost ~]$
```

j'ai internet : 
```
[cbenjamin@localhost ~]$ curl google.com
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY></HTML>
[cbenjamin@localhost ~]$
```
route par défault 
```
[cbenjamin@localhost ~]$ ip r s
default via 10.0.2.2 dev enp0s3 proto dhcp metric 100
10.0.2.0/24 dev enp0s3 proto kernel scope link src 10.0.2.15 metric 100
192.168.1.0/24 dev enp0s8 proto kernel scope link src 192.168.1.6 metric 101
[cbenjamin@localhost ~]$
```

ping de node2 vers node1
```
[cbenjamin@localhost ~]$ ping 192.168.1.7
PING 192.168.1.12 (192.168.1.12) 56(84) bytes of data.
64 bytes from 192.168.1.7: icmp_seq=1 ttl=255 time=0.630 ms
64 bytes from 192.168.1.7: icmp_seq=2 ttl=255 time=0.813 ms
64 bytes from 192.168.1.7: icmp_seq=3 ttl=255 time=0.767 ms
64 bytes from 192.168.1.7: icmp_seq=4 ttl=255 time=0.415 ms
```
pong 


ping de node1 vers node2
```
[cbenjamin@localhost ~]$ ping 192.168.1.6
PING 192.168.1.6 (192.168.1.6) 56(84) bytes of data.
64 bytes from 192.168.1.6: icmp_seq=1 ttl=255 time=0.630 ms
64 bytes from 192.168.1.6: icmp_seq=2 ttl=255 time=0.785 ms
64 bytes from 192.168.1.6: icmp_seq=3 ttl=255 time=0.854 ms
64 bytes from 192.168.1.6: icmp_seq=4 ttl=255 time=0.598 ms
```

```
[cbenjamin@node1 ~]$ hostname
node1.tp1.b2
```
```
[cbenjamin@node2 ~]$ hostname
node2.tp1.b2
[cbenjamin@node2 ~]$
```

ping de node1 vers node2
```
[cbenjamin@node1 ~]$ ping node2.tp1.b2
PING node2.tp1.b2 (192.168.1.7) 56(84) bytes of data.
64 bytes from node2.tp1.b2 (192.168.1.7): icmp_seq=1 ttl=64 time=1.24 ms
64 bytes from node2.tp1.b2 (192.168.1.7): icmp_seq=2 ttl=64 time=0.906 ms
64 bytes from node2.tp1.b2 (192.168.1.7): icmp_seq=3 ttl=64 time=0.785 ms
```
ping de node2 vers node1
```
[cbenjamin@node2 ~]$ ping node1.tp1.b2
PING node1.tp1.b2 (192.168.1.6) 56(84) bytes of data.
64 bytes from node1.tp1.b2 (192.168.1.6): icmp_seq=1 ttl=64 time=0.854 ms
64 bytes from node1.tp1.b2 (192.168.1.6): icmp_seq=2 ttl=64 time=0.805 ms
64 bytes from node1.tp1.b2 (192.168.1.6): icmp_seq=3 ttl=64 time=0.714 ms
```


Bonjour PHILIPE
```
[cbenjamin@node1 ~]$ adduser PHILIPE
adduser: Permission denied.
adduser: cannot lock /etc/passwd; try again later.
[cbenjamin@node1 ~]$ sudo !!
sudo adduser PHILIPE
[sudo] Mot de passe de cbenjamin : 
[cbenjamin@node1 ~]$ passwd PHILIPE
passwd : Seul le super-utilisateur peut indiquer un nom d'utilisateur.
[cbenjamin@node1 ~]$ suso !!
suso passwd PHILIPE
-bash: suso : commande introuvable
[cbenjamin@node1 ~]$ sudo passwd PHILIPE
Changement de mot de passe pour l'utilisateur PHILIPE.
Nouveau mot de passe :
MOT DE PASSE INCORRECT : Le mot de passe comporte moins de 8 caractères
Retapez le nouveau mot de passe :
passwd : mise à jour réussie de tous les jetons d'authentification.
[cbenjamin@node1 ~]$
```

sudo pour le Philipe 
```
[PHILIPE@node1 ~]$ sudo ls -al /root

Nous espérons que vous avez reçu de votre administrateur système local les consignes traditionnelles. Généralement, elles se concentrent sur ces trois éléments :

    #1) Respectez la vie privée des autres.
    #2) Réfléchissez avant d'utiliser le clavier.
    #3) De grands pouvoirs confèrent de grandes responsabilités.

[sudo] Mot de passe de PHILIPE : 
total 24
dr-xr-x---.  2 root root  114 13 nov.   2019 .
dr-xr-xr-x. 17 root root  224 13 nov.   2019 ..
-rw-------.  1 root root 1516 13 nov.   2019 anaconda-ks.cfg
-rw-r--r--.  1 root root   18 29 déc.   2013 .bash_logout
-rw-r--r--.  1 root root  176 29 déc.   2013 .bash_profile
-rw-r--r--.  1 root root  176 29 déc.   2013 .bashrc
-rw-r--r--.  1 root root  100 29 déc.   2013 .cshrc
-rw-r--r--.  1 root root  129 29 déc.   2013 .tcshrc
[PHILIPE@node1 ~]$
```
Bonjour FRANCIS
```
[FRANCIS@node2 ~]$ sudo ls -al /root

Nous espérons que vous avez reçu de votre administrateur système local les consignes traditionnelles. Généralement, elles se concentrent sur ces trois éléments :

    #1) Respectez la vie privée des autres.
    #2) Réfléchissez avant d'utiliser le clavier.
    #3) De grands pouvoirs confèrent de grandes responsabilités.

[sudo] Mot de passe de FRANCIS : 
total 24
dr-xr-x---.  2 root root  114 13 nov.   2019 .
dr-xr-xr-x. 17 root root  224 13 nov.   2019 ..
-rw-------.  1 root root 1516 13 nov.   2019 anaconda-ks.cfg
-rw-r--r--.  1 root root   18 29 déc.   2013 .bash_logout
-rw-r--r--.  1 root root  176 29 déc.   2013 .bash_profile
-rw-r--r--.  1 root root  176 29 déc.   2013 .bashrc
-rw-r--r--.  1 root root  100 29 déc.   2013 .cshrc
-rw-r--r--.  1 root root  129 29 déc.   2013 .tcshrc
[FRANCIS@node2 ~]$
```

adieu se linux :
```
[cbenjamin@node1 ~]$ sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   permissive
Mode from config file:          permissive
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Max kernel policy version:      31
[cbenjamin@node1 ~]$
```
```
[cbenjamin@node2 ~]$ sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   permissive
Mode from config file:          permissive
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Max kernel policy version:      31
[cbenjamin@node2 ~]$
```


ducou pour des raison chelou (problèmes sur mon pc) l'ip des machines diffèrents de l'énconcé.
voici l'ip de mes machines : 

Node1 : 192.168.1.6

Node2 : 192.168.1.7


## I. Setup serveur web 


j'ai installer nginx sur les deux vms en faisant un ``sudo yum update`` puis ```sudo yum install epel-release```et enfin le famuex ``sudo yum install nginx``

on le démarre ``sudo systemctl start nginx ``

On crée les index.html :

```
[cbenjamin@node1 ~]$ sudo touch /srv/site1/index.html
[cbenjamin@node1 ~]$ sudo touch /srv/site2/index.html
```

dans les fichiers de site1 et site 2 j'ai rentré respectivement :

``index du premier site``

``index du deuxième site``



op on met les perms :
```
[cbenjamin@node1 ~]$ sudo chmod -R 755 /srv/site1/
[cbenjamin@node1 ~]$ sudo chmod -R 755 /srv/site2/
```

on attribut les dossier à un utilisateur et un groupe : 
```
[cbenjamin@node1 ~]$ sudo chown -R cbenjamin:cbenjamin /srv/site1
[cbenjamin@node1 ~]$ sudo chown -R cbenjamin:cbenjamin /srv/site2
```

vérifs :

```
[cbenjamin@node1 ~]$ ls -al /srv/site1
total 24
drwxr-xr-x. 3 cbenjamin cbenjamin  4096 28 sept. 14:53 .
drwxr-xr-x. 4 root      root         32 24 sept. 14:33 ..
-rwxr-xr-x. 1 cbenjamin cbenjamin    22 28 sept. 14:53 index.html
drwxr-xr-x. 2 cbenjamin cbenjamin 16384 24 sept. 14:31 lost+found
[cbenjamin@node1 ~]$ ls -al /srv/site2
total 24
drwxr-xr-x. 3 cbenjamin cbenjamin  4096 28 sept. 14:53 .
drwxr-xr-x. 4 root      root         32 24 sept. 14:33 ..
-rwxr-xr-x. 1 cbenjamin cbenjamin    24 28 sept. 14:53 index.html
drwxr-xr-x. 2 cbenjamin cbenjamin 16384 24 sept. 14:31 lost+found
[cbenjamin@node1 ~]$
```
le propriétaire est cbenjamin 
le groupe est cbenjamin 
cbenjamin peut lire, écrire et exécuter dans le fichier. les autres ne peuvent que le lire et l'exécuter 


Ensuite on va ouvrir les ports :
```
[cbenjamin@node1 ~]$ sudo firewall-cmd --zone=public --add-service=http
success
[cbenjamin@node1 ~]$ sudo firewall-cmd --zone=public --add-service=https
success
[cbenjamin@node1 ~]$
```

bon on va génèrer notre certificat pour https :
```
[cbenjamin@node1 ~]$ openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout server.key -out server.crt
Generating a 2048 bit RSA private key
............................................+++
...................................................................................+++
writing new private key to 'server.key'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:
State or Province Name (full name) []:
Locality Name (eg, city) [Default City]:
Organization Name (eg, company) [Default Company Ltd]:
Organizational Unit Name (eg, section) []:
Common Name (eg, your name or your server's hostname) []:node1.tp1.b2
Email Address []:
[cbenjamin@node1 ~]$
```

et op on les mouv : 
```
[cbenjamin@node1 ~]$ sudo mv server.crt /etc/nginx/
[sudo] Mot de passe de cbenjamin : 
[cbenjamin@node1 ~]$ sudo mv server.key /etc/nginx/
```

Voici mon fichier conf pour nginx :
```
[cbenjamin@node1 ~]$ sudo vim /etc/nginx/nginx.conf
[cbenjamin@node1 ~]$ cat /etc/nginx/nginx.conf
worker_processes 1;
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

        server_name node1.tp1.b2;
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
    }
}
[cbenjamin@node1 ~]$
```

Maintenant on va se connecter aux 2 sites avec node2 :

__site 1__: 
```
[cbenjamin@node2 ~]$ curl -L node1.tp1.b2/site1
index du premier site
[cbenjamin@node2 ~]$
```

__site 2__:
```
[cbenjamin@node2 ~]$ curl -L node1.tp1.b2/site2
index du deuxième site
[cbenjamin@node2 ~]$
```

on va le refaire mais en https :

__site 1__:
```
[cbenjamin@node2 ~]$ curl -kL https://node1.tp1.b2/site1
index du premier site
[cbenjamin@node2 ~]$   
```

__site 2__:
```
[cbenjamin@node2 ~]$ curl -kL https://node1.tp1.b2/site2
index du deuxième site
[cbenjamin@node2 ~]$
```
donc on vient de prouver que node 2 peut joindre les sites en http et https

## II. Script de sauvegarde 

je vais créer le fichier du script, un dossier sauvegarde et enfin deux dossier site1 et site2 dans sauvegarde :

```
[cbenjamin@node1 ~]$ touch tp1_backup.sh
[cbenjamin@node1 ~]$ mkdir sauvegarde
[cbenjamin@node1 ~]$ mkdir sauvegarde/site1
[cbenjamin@node1 ~]$ mkdir sauvegarde//site2
[cbenjamin@node1 ~]$ cd sauvegarde/
[cbenjamin@node1 sauvegarde]$ ls
site1  site2
[cbenjamin@node1 sauvegarde]$
```

### III. Monitoring, alerting

j'installe netdate avec cette commande : ``bash <(curl -Ss https://my-netdata.io/kickstart.sh)``

ensuite j'ouvre le port avec la commande suivante :
```
[cbenjamin@node1 ~]$ sudo firewall-cmd --add-port=19999/tcp --permanent
success
[cbenjamin@node1 ~]$
```

on crée un webhook dans un serveur discord.

on modifie le fichier ``/etc/netdata/edit-config health_alarm_notify.conf`` 
et on met dans la ligne ``DISCORD_WEBHOOK_URL=""`` le lien de notre webhook 
soit https://discordapp.com/api/webhooks/760160345380749361/e51F87xXEZ58YSGAddkx5WWugAG3Mj0k99aKms9TOsMhM1CQ8mqGRvWyVimVcToNChz4 pur le miens

et enfin on modifie le fichier conf de nginx : 

```
worker_processes 1;
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

        server_name node1.tp1.b2;
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
            proxy_set_header Host $host;

            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Server $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_http_version 1.1;
            proxy_pass_request_headers on;
            proxy_set_header Connection "keep-alive";
            proxy_store off;
            proxy_pass http://netdata/$ndpath$is_args$args;

            gzip on;
            gzip_proxied any;
            gzip_types *;
        }
    }
}
```