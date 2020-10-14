# TP 4 : Déploiment multi-noeud

sommaire :
*   [I. Consignes générales](##-I-:-Consignes-générales)
*   [II. Présentation de la stack](##-II-:-Présentation-de-la-stack)
    *   [1. Gitea](###-1-:-Gitea-)
    *   [2. MariaDB](###-2-:-MariaDB)
    *   [3. NGINX](###-3-:-NGINX)
    *   [4. Serveur NFS](###-4-:-Serveur-NFS)
    *   [5. Sauvegarde](###-5-:-Sauvegarde)
    *   [6. Monitoring](###-6-:-Monitoring)
    *   [7. Bonus](###-7-:-Bonus)
        *   []()
        *   []()

## I : Consignes générales

_"cette partie n'est qu'une présentation. Vous trouverez une suite d'étapes dans le II."_ 

bah yes 
ducou let's go II.

sauf que avant je vais te présenter despi mes vm : 

| Name           | IP           | Rôle        |
| -------------- | ------------ | ----------- |
| node1.tp4.b2 | 192.168.4.41 | Gitea       |
| node2.tp4.b2 | 192.168.4.42 | MariaDB     |
| node3.tp4.b2 | 192.168.4.43 | NGINX       |
| node4.tp4.b2 | 192.168.4.44 | Serveur NFS |

## II : Présentation de la stack

### 1 : Gitea

