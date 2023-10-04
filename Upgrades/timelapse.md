# Moonraker-timelapses

Ne pas utiliser le «make install» du dépôt cloné => moonraker utilise une autre structure pour les configurations :

**~/printer_data/config** alors que QidiTech utilise encore l'ancien chemin **~/klipper_config**

## Utiliser des liens symoboliques

Cloner le dépôt :

```
mks@mkspi:~$ git clone https://github.com/mainsail-crew/moonraker-timelapse.git
Cloning into 'moonraker-timelapse'...
remote: Enumerating objects: 526, done.
remote: Counting objects: 100% (203/203), done.
remote: Compressing objects: 100% (70/70), done.
remote: Total 526 (delta 148), reused 154 (delta 128), pack-reused 323
Receiving objects: 100% (526/526), 187.75 KiB | 2.44 MiB/s, done.
Resolving deltas: 100% (264/264), done.
mks@mkspi:~$
```
Vérifier le contenu du dossier:

```
mks@mkspi:~/moonraker-timelapse$ ls -al
total 80
drwxr-xr-x  8 mks mks  4096 Aug 21 11:42 .
drwxr-xr-x 34 mks mks  4096 Aug 21 11:42 ..
drwxr-xr-x  2 mks mks  4096 Aug 21 11:42 component
drwxr-xr-x  3 mks mks  4096 Aug 21 11:42 docs
-rw-r--r--  1 mks mks   357 Aug 21 11:42 .editorconfig
drwxr-xr-x  8 mks mks  4096 Aug 21 11:42 .git
drwxr-xr-x  3 mks mks  4096 Aug 21 11:42 .github
drwxr-xr-x  2 mks mks  4096 Aug 21 11:42 klipper_macro
-rw-r--r--  1 mks mks 35149 Aug 21 11:42 LICENSE
-rw-r--r--  1 mks mks  1033 Aug 21 11:42 Makefile
-rw-r--r--  1 mks mks   917 Aug 21 11:42 README.md
drwxr-xr-x  2 mks mks  4096 Aug 21 11:42 scripts
mks@mkspi:~/moonraker-timelapse$ ls -al component/
total 44
drwxr-xr-x 2 mks mks  4096 Aug 21 11:42 .
drwxr-xr-x 8 mks mks  4096 Aug 21 11:42 ..
-rw-r--r-- 1 mks mks 33767 Aug 21 11:42 timelapse.py
mks@mkspi:~/moonraker-timelapse$ ls -al klipper_macro/
total 32
drwxr-xr-x 2 mks mks  4096 Aug 21 11:42 .
drwxr-xr-x 8 mks mks  4096 Aug 21 11:42 ..
-rw-r--r-- 1 mks mks 22348 Aug 21 11:42 timelapse.cfg
mks@mkspi:~/moonraker-timelapse$
```
Créer des liens symboliques pour le fichier Python et le fichier de configuration :

```
mks@mkspi:~/moonraker-timelapse$ ln -sf "/home/mks/moonraker-timelapse/component/timelapse.py" "/home/mks/moonraker/moonraker/components/timelapse.py"
mks@mkspi:~/moonraker-timelapse$ ls -l ../moonraker/moonraker/components/timelapse.py
lrwxrwxrwx 1 mks mks 52 Aug 21 11:46 ../moonraker/moonraker/components/timelapse.py -> /home/mks/moonraker-timelapse/component/timelapse.py
mks@mkspi:~/moonraker-timelapse$
mks@mkspi:~/moonraker-timelapse$ ln -sf "/home/mks/moonraker-timelapse/klipper_macro/timelapse.cfg" "/home/mks/klipper_config/timelapse.cfg"
mks@mkspi:~/moonraker-timelapse$ ls -l ../klipper_config/timelapse.cfg
lrwxrwxrwx 1 mks mks 57 Aug 21 11:49 ../klipper_config/timelapse.cfg -> /home/mks/moonraker-timelapse/klipper_macro/timelapse.cfg
mks@mkspi:~/moonraker-timelapse$
```

## Mettre à jour moonraker.conf en ajoutant la section «timelapse»

```
[timelapse]
output_path: ~/klipper_config/timelapses
frame_path: ~/klipper_config/timelapse/tmp
```

Créer les odssiers timelapses et timelapses/tmp (normalement inutile mais principe "ceintures + bretelles") :

```
mkdir -p ~/mks/klipper_config/timelapses/tmp
```

**IMPORTANT**:

L'espace disponible sur l'eMMC de 8 Go est très limitée (≃ 512 Mo), il serait juiicieux soit 
 - de remplacer l'EMMC par une de taille plus grande (16, 32 Go)
 - monter une clé USB pour servir de stockage et indiquer dans la section [virtual_sdcard] du printer.cfg son point de montage

```
[virtual_sdcard]
path:/mnt/nom-du-point-de-montage
```
