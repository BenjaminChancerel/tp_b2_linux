# TP 3 : Systemd

[file](./file)

sommaire :

*   [I. Services systemd](#I-:-Services-systemd)
    *   [1. Intro](#1-:-Intro)
    *   [2. Analyse d'un service](#2-:-Analyse-d'un-service)
    *   [3. Création d'un service](#3-:-Création-d'un-service)
        *   [A. Serveur web](#A-:-Serveur-web)       

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

