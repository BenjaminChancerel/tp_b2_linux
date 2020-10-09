# TP 3 : Systemd

[file](./file)

sommaire :

*   [I. Services systemd](##-I-:-Services-systemd)
    *   [1. Intro](###-1-:-Intro)
    *   [2. Analyse d'un service](###-2-:-Analyse-d'un-service)
    *   [3. Création d'un service](###-3-:-Création-d'un-service)
        *   [A. Serveur web](####-A-:-Serveur-web)
        *   [B. Sauvegrade](####-B-:-Sauvegrade)     
*   [II. Autres features](##-II-:-Autres-features)
    *   [1. Gestion boot](###-1-:-Gestion-de-boot)
    *   [2. Gestion de l'heure](###-2-:-Gestion-de-l'heure)
    *   [3. Gestion des noms et de la résolution des noms](###-3-:-Gestion-des-noms-et-de-la-résolution-de-noms)
## I : Services systemd

### 1 : Intro

- afficher le nombre de ``services systemd`` disos sur la machine :

```
[vagrant@tp3 ~]$ sudo systemctl list-unit-files -t service -a | grep service | wc -l
154
[vagrant@tp3 ~]$
```

- afficher le nombre de ``services systemd`` actifs et en cours d'exécution ("_running_") sur la machine :

```
[vagrant@tp3 ~]$ sudo systemctl -t service | grep running | wc -l
16
[vagrant@tp3 ~]$
```

- afficher le nomdre de ``services systemd`` qui ont échoué ("_failed_") ou qui sont inactifs ("_exited_") sur la machine :

```
[vagrant@tp3 ~]$ sudo systemctl -t service -a | grep -E 'exited|failed' | wc -l
17
[vagrant@tp3 ~]$
```

- afficher le nombre de ``services systemd`` qui démarrent automatiquement au boot ("_enabled_") :

```
[vagrant@tp3 ~]$ sudo systemctl -t service -a | grep -E 'exited|failed' | wc -l
17
[vagrant@tp3 ~]$
```

### 2 : Analyse d'un service 

On va étudier le service __nginx.service__ :

- on va d'abord déterminer son path : 
```
[vagrant@tp3 ~]$ systemctl status nginx.service
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: inactive (dead)
[vagrant@tp3 ~]$
```
le voici __``Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)``__

*   afficher son contenu et expliquer les lignes qui comportent :

    *   ``ExecStart`` :
        __ExecStart=/usr/sbin/nginx__ : cette ligne définit la commande à exécuter pour démarrer l'application
    *   ``ExecStartPre`` : c'est la commande qui est exécutée avant ExecStart (bi1 vU bG)

        __ExecStartPre=/usr/bin/rm -f /run/nginx.pid__ : 

        __ExecStartPre=/usr/sbin/nginx -t__


    *   ``PIDFile`` : __PIDFile=/run/nginx.pid__ :
        cette ligne définit le nom du fichier dans lequel le serveur enregistre son identifiant de processus (PID).
    *   ``Type`` : __Type=forking__ : cette ligne configure le type de démarrage de processus d'unité qui affecte la fonctionalité d'``ExecStart`` et des options connexes.

        l'option que contient notre service est ``forking``: le processus lancé par ``ExecStart`` engendre un processus _enfant_ qui devient le processus principale du service. Le processus parent s'arrête lorsque le startup est terminé. 
    *   ``ExecReload`` : __ExecReload=/bin/kill -s HUP $MAINPID__ Spécifie les commandes ou scripts à exécuter lorsque l'unité est rechargée
    *   ``Description`` : __Description=The nginx HTTP and reverse proxy server__ Description significative de l'unité. Le texte ressort de la commande ``systemctl status nginx.service``
    *   ``After`` : __After=network.target remote-fs.target nss-lookup.target__ Définit l'ordre dans lequel les unités sont lancées. L'unité est lancée uniquement après l'activation des unités spécifiées dans ``After``

voici le cat en entier : 
```
[vagrant@tp3 ~]$ systemctl cat nginx.service
# /usr/lib/systemd/system/nginx.service
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
# Nginx will fail to start if /run/nginx.pid already exists but has the wrong
# SELinux context. This might happen when running `nginx -t` from the cmdline.
# https://bugzilla.redhat.com/show_bug.cgi?id=1268621
ExecStartPre=/usr/bin/rm -f /run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=process
PrivateTmp=true

[Install]
WantedBy=multi-user.target
[vagrant@tp3 ~]$    
```

__Listez tous les services qui contiennent la ligne ``WantedBy=multi-user.target``__ : à voir plus tard 

### 3 : Création d'un service

#### A : Serveur Web

```
[vagrant@tp3 ~]$ python3 -m http.server 8080
Serving HTTP on 0.0.0.0 port 8080 (http://0.0.0.0:8080/) ...
192.168.2.1 - - [07/Oct/2020 12:22:24] "GET / HTTP/1.1" 200 -
192.168.2.1 - - [07/Oct/2020 12:22:24] code 404, message File not found
192.168.2.1 - - [07/Oct/2020 12:22:24] "GET /favicon.ico HTTP/1.1" 404 -
```
j'ai lancé le serveur web 

ok donc voici la conf de mon serveur web :
```
[vagrant@tp3 system]$ cat web.service
[Unit]
Description=web server for leo's tp

[Service]
Type=simple
user=nginx
Environment="PORT=8080"
ExecStartPre=+/usr/bin/firewalld --add-port=${PORT}/tcp
ExecStart=/usr/bin/python3 -m http.server ${PORT}
ExecStop=+/usr/bin/firewalld --remove-port=${PORT}/tcp

[Install]
WantedBy=multi-user.target
[vagrant@tp3 system]$
```

voire le fichier en détail sur _[file](./file)_


on va tester avec un __curl__ :

```
[vagrant@tp3 system]$ curl 192.168.2.11:8080
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Directory listing for /</title>
</head>
<body>
<h1>Directory listing for /</h1>
<hr>
<ul>
<li><a href="bin/">bin@</a></li>
<li><a href="boot/">boot/</a></li>
<li><a href="dev/">dev/</a></li>
<li><a href="etc/">etc/</a></li>
<li><a href="home/">home/</a></li>
<li><a href="lib/">lib@</a></li>
<li><a href="lib64/">lib64@</a></li>
<li><a href="media/">media/</a></li>
<li><a href="mnt/">mnt/</a></li>
<li><a href="opt/">opt/</a></li>
<li><a href="proc/">proc/</a></li>
<li><a href="root/">root/</a></li>
<li><a href="run/">run/</a></li>
<li><a href="sbin/">sbin@</a></li>
<li><a href="srv/">srv/</a></li>
<li><a href="swapfile">swapfile</a></li>
<li><a href="sys/">sys/</a></li>
<li><a href="tmp/">tmp/</a></li>
<li><a href="usr/">usr/</a></li>
<li><a href="var/">var/</a></li>
</ul>
<hr>
</body>
</html>
[vagrant@tp3 system]$
```
ça marche zebi 

on va vérif encore avec un __status__ :

```
[vagrant@tp3 ~]$ sudo systemctl status web
● web.service - web server for leo's tp
   Loaded: loaded (/etc/systemd/system/web.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2020-10-07 13:17:52 UTC; 5min ago
 Main PID: 2656 (python3)
   CGroup: /system.slice/web.service
           └─2656 /usr/bin/python3 -m http.server 8080

Oct 07 13:17:52 tp3 systemd[1]: [/etc/systemd/system/web.service:6] Unknown lvalue 'user' in section 'Service'
Oct 07 13:17:52 tp3 systemd[1]: [/etc/systemd/system/web.service:8] Executable path is not absolute, ignorin...T}/tcp
Oct 07 13:17:52 tp3 systemd[1]: [/etc/systemd/system/web.service:10] Executable path is not absolute, ignori...T}/tcp
Oct 07 13:17:52 tp3 systemd[1]: Started web server for leo's tp.
Hint: Some lines were ellipsized, use -l to show in full.
```

maintenant on va faire en sorte que le system __s'allume au démarrage de ma machine__ :

```
[vagrant@tp3 ~]$ sudo systemctl enable web
Created symlink from /etc/systemd/system/multi-user.target.wants/web.service to /etc/systemd/system/web.service.
[vagrant@tp3 ~]$
```

carré dans l'axe

#### B : Sauvegarde 

comme tu as surement pu le voire, j'ai pas réussi à faire de script au tp 1.
Donc je vais utiliser celui de quelqu'un d'autre (celui de gauthier :) cimer le gaut )

tu peux le retouvrer dans _[file](./file)_

je split donc le script en trois script comme demandés :
*   _prebackup.sh_
*   _backup.sh_
*   _postbackup.sh_

tu les retrouves dans _[file](./file)_

tu retrouveras aussi le fichier _backup.service_ 

je ne sais pas pk j'ai une erreur invalid argument que je n'arrive pas à régler ... donc je ne l'ai pas tester.

donc soit ça marche pour toi soit bah ... 💩

j'ai quand même fait un backup.timer

## II : Autres features 

### 1 : Gestion de boot

voici la commande que j'ai rentrer pour obtenir le diagramme de boot dans un fichier .svg : `` sudo systemd-analyze plot >bootup.svg     ``


je vois ur le diagramme que les 3 services les plus lents à demarrer sont :

*   __kdump.service__ : _168ms_
*   __rsyslog.service__ : _77ms_
*   __rpc-statd-notify.service__ : _37ms_

### 2 : Gestion de l'heure

```
[vagrant@tplinux3 ~]$ timedatectl
               Local time: Wed 2020-10-07 19:49:46 UTC
           Universal time: Wed 2020-10-07 19:49:46 UTC
                 RTC time: Wed 2020-10-07 19:49:43
                Time zone: UTC (UTC, +0000)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
[vagrant@tplinux3 ~]$
```

``Time zone: UTC (UTC, +0000)`` : voici la ligne qui m'indique mon fuseau horaire, le fuseau du méridien de Greenwich

``NTP service: active`` : le on peut lire que je suis synchro avec un serveur __NTP__

*   Pour changer mon fuseau horaire :

    *   D'abord je liste les fuseaux horaires avec ``timedatectl list-timezones`` 
    *   je repère ``Europe/Paris``
    *   et je rentre la commande ``sudo timedatectl set-timezone Europe/Paris``

on vérifie le fuseau : 

```
[vagrant@tplinux3 ~]$ timedatectl
               Local time: Wed 2020-10-07 21:59:04 CEST
           Universal time: Wed 2020-10-07 19:59:04 UTC
                 RTC time: Wed 2020-10-07 19:59:02
                Time zone: Europe/Paris (CEST, +0200)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
[vagrant@tplinux3 ~]$
```

on constate que l'heure locale à pris 2h 
normale on est en france heure d'été tu connais 

### 3 : Gestion des noms et de la résolution de noms

```
[vagrant@tplinux3 ~]$ hostnamectl
   Static hostname: tplinux3
         Icon name: computer-vm
           Chassis: vm
        Machine ID: dc4157234e15404d927c7e1535b42b44
           Boot ID: c5c743696c6e4f609126de20f273cc35
    Virtualization: oracle
  Operating System: CentOS Linux 8 (Core)
       CPE OS Name: cpe:/o:centos:centos:8
            Kernel: Linux 4.18.0-80.el8.x86_64
      Architecture: x86-64
[vagrant@tplinux3 ~]$ hostnamectl
   Static hostname: tplinux3
         Icon name: computer-vm
           Chassis: vm
        Machine ID: dc4157234e15404d927c7e1535b42b44
           Boot ID: c5c743696c6e4f609126de20f273cc35
    Virtualization: oracle
  Operating System: CentOS Linux 8 (Core)
       CPE OS Name: cpe:/o:centos:centos:8
            Kernel: Linux 4.18.0-80.el8.x86_64
      Architecture: x86-64
```

Mon hostname actuel : __``Static hostname: tplinux3``__

```
[vagrant@tplinux3 ~]$ sudo hostnamectl set-hostname LeRoiDRoux
[vagrant@tplinux3 ~]$ hostnamectl
   Static hostname: LeRoiDRoux
         Icon name: computer-vm
           Chassis: vm
        Machine ID: dc4157234e15404d927c7e1535b42b44
           Boot ID: c5c743696c6e4f609126de20f273cc35
    Virtualization: oracle
  Operating System: CentOS Linux 8 (Core)
       CPE OS Name: cpe:/o:centos:centos:8
            Kernel: Linux 4.18.0-80.el8.x86_64
      Architecture: x86-64
[vagrant@tplinux3 ~]$
```
et op on a changé le hostname 



BISOUS