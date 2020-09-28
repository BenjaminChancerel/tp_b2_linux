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

__Pour Node1 :__

_site1_
```
[cbenjamin@node1 ~]$ sudo ls -al /srv/site1
total 20
drw-r--r--. 3 root      root       4096 24 sept. 16:46 .
drwxr-xr-x. 4 root      root         32 24 sept. 14:33 ..
-rw-r--r--. 1 cbenjamin cbenjamin     0 24 sept. 16:46 index.html
drwx------. 2 root      root      16384 24 sept. 14:31 lost+found
[cbenjamin@node1 ~]$
```

_site2_
```
[cbenjamin@node1 ~]$ ls -al /srv/site2
ls: impossible d'accéder à /srv/site2/..: Permission non accordée
ls: impossible d'accéder à /srv/site2/lost+found: Permission non accordée
ls: impossible d'accéder à /srv/site2/.: Permission non accordée
ls: impossible d'accéder à /srv/site2/index.html: Permission non accordée
total 0
d????????? ? ? ? ?              ? .
d????????? ? ? ? ?              ? ..
-????????? ? ? ? ?              ? index.html
d????????? ? ? ? ?              ? lost+found
[cbenjamin@node1 ~]$ sudo !!
sudo ls -al /srv/site2
total 20
drw-r--r--. 3 root      root       4096 24 sept. 16:46 .
drwxr-xr-x. 4 root      root         32 24 sept. 14:33 ..
-rw-r--r--. 1 cbenjamin cbenjamin     0 24 sept. 16:46 index.html
drwx------. 2 root      root      16384 24 sept. 14:31 lost+found
[cbenjamin@node1 ~]$
```

__Pour node2:__

_site1_
```
[cbenjamin@node2 ~]$ sudo ls -al /srv/site1
total 20
drw-r--r--. 3 root      root       4096 24 sept. 16:47 .
drwxr-xr-x. 4 root      root         32 24 sept. 14:33 ..
-rw-r--r--. 1 cbenjamin cbenjamin     0 24 sept. 16:47 index.html
drwx------. 2 root      root      16384 24 sept. 14:31 lost+found
[cbenjamin@node2 ~]$
```

_site2_

```
[cbenjamin@node2 ~]$ sudo ls -al /srv/site2
total 20
drw-r--r--. 3 root      root       4096 24 sept. 16:48 .
drwxr-xr-x. 4 root      root         32 24 sept. 14:33 ..
-rw-r--r--. 1 cbenjamin cbenjamin     0 24 sept. 16:48 index.html
drwx------. 2 root      root      16384 24 sept. 14:31 lost+found
[cbenjamin@node2 ~]$
```