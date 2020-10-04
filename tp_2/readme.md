q  # TP 2 : Déploiement automatisé 

## I. Déploiement simple

[part1](./part_1)

tema le vagrantfile : 
```

Vagrant.configure("2")do|config|
  config.vm.box="centos/7"
  config.vm.hostname="tp2"
  config.vm.network "private_network", ip: "192.168.2.11"

  ## Les 3 lignes suivantes permettent d'éviter certains bugs et/ou d'accélérer le déploiement. Gardez-les tout le temps sauf contre-indications.
  # Ajoutez cette ligne afin d'accélérer le démarrage de la VM (si une erreur 'vbguest' est levée, voir la note un peu plus bas)
  config.vbguest.auto_update = false

  # Désactive les updates auto qui peuvent ralentir le lancement de la machine
  config.vm.box_check_update = false 

  # La ligne suivante permet de désactiver le montage d'un dossier partagé (ne marche pas tout le temps directement suivant vos OS, versions d'OS, etc.)
  config.vm.synced_folder ".", "/vagrant", disabled: true

  #config taille de la ram
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
  end

  #config du nom de la machine 
  config.vm.provider :virtualbox do |vb|
    vb.name = "tp2_linux"
  end
end
```

vérifs 1 GO DE RAM :

```
[vagrant@tp2 ~]$ free -m
              total        used        free      shared  buff/cache   available
Mem:            990          84         793           6         113         776
Swap:          2047           0        2047
[vagrant@tp2 ~]$
```

vérif de l'ip statique : 

```
[vagrant@tp2 ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:4d:77:d3 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
       valid_lft 86220sec preferred_lft 86220sec
    inet6 fe80::5054:ff:fe4d:77d3/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:c7:59:2e brd ff:ff:ff:ff:ff:ff
    inet 192.168.2.11/24 brd 192.168.2.255 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fec7:592e/64 scope link
       valid_lft forever preferred_lft forever
[vagrant@tp2 ~]$
```
et pour le hostname : 
```
[vagrant@tp2 ~]$
```

voici ce que j'ai mis dans le script sh pour installer vim :

```
sudo yum install vim -y
```
et ça marche 

voici ce que j'ai ajouté dans le vigrant file 

```
disk = './secondDisk.vdi'
  config.vm.provider "virtualbox" do |vb|
    unless File.exist?(disk)
      vb.customize ['createhd', '--filename',disk , '--variant', 'Fixed', '--size', 5 * 1024]
    end
    vb.customize ['storageattach', :id, '--storagectl', 'IDE', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', disk]
    end
```

et maintenant j'ai un deuxième disque de 5 go :
```
[vagrant@tp2 ~]$ lsblk
NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
sda      8:0    0  40G  0 disk
└─sda1   8:1    0  40G  0 part /
sdb      8:16   0   5G  0 disk
[vagrant@tp2 ~]$
```
## II. Re-package

t'as pas mis de soleil 

## III. Multi-node deployement

[part3](./part_3)

ok ducou j'ai fait un vagrantfile que tu trouvera dans part_3

la c'est les vérifs sur les vms 

__pour node1 :__

ip locale :

```
[vagrant@node1 ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:4d:77:d3 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
       valid_lft 85734sec preferred_lft 85734sec
    inet6 fe80::5054:ff:fe4d:77d3/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:33:4c:4f brd ff:ff:ff:ff:ff:ff
    inet 192.168.2.21/24 brd 192.168.2.255 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe33:4c4f/64 scope link
       valid_lft forever preferred_lft forever
[vagrant@node1 ~]$       
```

hostname : 
```
[vagrant@node1 ~]$ hostname
node1.tp2.b2
[vagrant@node1 ~]$
```

ram : 
```
[vagrant@node1 ~]$ free -m
              total        used        free      shared  buff/cache   available
Mem:            990         129         457           6         403         701
Swap:          2047           0        2047
[vagrant@node1 ~]$
```

__pour node2 :__


pour l'ip locale :
```
[vagrant@node2 ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:4d:77:d3 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
       valid_lft 86024sec preferred_lft 86024sec
    inet6 fe80::5054:ff:fe4d:77d3/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:21:d0:7c brd ff:ff:ff:ff:ff:ff
    inet 192.168.2.22/24 brd 192.168.2.255 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe21:d07c/64 scope link
       valid_lft forever preferred_lft forever
[vagrant@node2 ~]$
```

hostname : 
```
[vagrant@node2 ~]$ hostname
node2.tp2.b2
[vagrant@node2 ~]$
```

ram : 
```
[vagrant@node2 ~]$ free -m
              total        used        free      shared  buff/cache   available
Mem:            486          70         218           2         197         401
Swap:          2047          23        2024
[vagrant@node2 ~]$
```

## IV. Automation here we (slowly) come

[part4](./part4)