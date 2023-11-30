## Présqerver l'historique des impressions

A chaque mise à jour si aucune précuation n'a été prise, l'historique des impressions est remis à zéro ☹️

Il est possible de faire une sauvegarde de la base de données pour pouvoir ensuite la réinjecter.

### Comment faire ?

1. Connecté en ssh sur la carte, installer le paquet `lmdb-utils` (sudo apt install lmdb-utils)
```
mks@mkspi:~$ sudo apt install lmdb-utils
[sudo] password for mks:
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following NEW packages will be installed:
  lmdb-utils
0 upgraded, 1 newly installed, 0 to remove and 197 not upgraded.
Need to get 54.6 kB of archives.
After this operation, 338 kB of additional disk space will be used.
Get:1 http://deb.debian.org/debian buster/main arm64 lmdb-utils arm64 0.9.22-1 [54.6 kB]
Fetched 54.6 kB in 0s (374 kB/s)
Selecting previously unselected package lmdb-utils.
(Reading database ... 144235 files and directories currently installed.)
Preparing to unpack .../lmdb-utils_0.9.22-1_arm64.deb ...
Unpacking lmdb-utils (0.9.22-1) ...
Setting up lmdb-utils (0.9.22-1) ...
Processing triggers for man-db (2.8.5-2) ...
```
2. Faire une sauvegarde de la base dans un fichier texte :
```
mks@mkspi:~$ cd ~
mks@mkspi:~$ mdb_dump -f bkup-moonraker-db.txt -a .moonraker_database
```
3. Faire la mise à jour Qidi
4. Toujours connecté en ssh, utilisateur «**mks**»
   4.1 Arrêter le daemon «moonraker»
       ```
       sudo systemctl stop moonraker
       ```
   4.2 Supprimer les deux fichiers du répertoire .moonraker_database (répertoire caché)
       ```
       cd .moonraker_database
       rm -rf data.mdb
       rm -rf lock.mdb
       ```
   4.3 Remonter à la racine du répertoire personnel (/home/mks)
       ```
       cd ~
       mdb_load -f bkup-moonraker-db.txt -s -T ~/.moonraker_database
       sudo systemctl start moonraker
       
       ```   

Source: [Voron Community Documentation](https://docs.vorondesign.com/community/howto/kyleisah/transferring_machine_history.html#something-went-wrong-moonraker-isnt-coming-back-up)
