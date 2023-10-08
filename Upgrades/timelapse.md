# Moonraker-timelapses

Ne pas utiliser le «make install» du dépôt cloné => 
- Moonraker utilise un autre chemin d'accès pour enregistrer les fichiers de configurations ( **~/printer_data/config** )
- QidiTech utilise encore l'ancien chemin ( **~/klipper_config** )

Manipulations à réaliser en accès `ssh` en tant qu'utilisateur **mks** (mot de passe: *makerbase*) 

## Installation

1. Cloner le dépôt :

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
2. Vérifier le contenu du dossier:

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
3. Créer des liens symboliques pour le fichier Python et le fichier de configuration, plutôt que copier ces fichiers dans ~/moonraker/components et ~/klipper_config (*en procédant ainsi ces fcihers seront toujours à jour même après mise à jour du dépôt "moonraker-timelapse"*) :

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

## Mettre à jour moonraker.conf en ajoutant la section minimale «timelapse»

```
[timelapse]
##   Following basic configuration is default to most images and don't need
##   to be changed in most scenarios. Only uncomment and change it if your
##   Image differ from standart installations. In most common scenarios
##   a User only need [timelapse] in their configuration.
#output_path: ~/klipper_config/timelapse/
##   Directory where the generated video will be saved
#frame_path: /tmp/timelapse/klipper_config
##   Directory where the temporary frames are saved
#ffmpeg_binary_path: /usr/bin/ffmpeg
##   Directory where ffmpeg is installed
```

Ma section [timelapse] comprend en plus les paramètres :
< Paramètres >

```
#enabled: True
#mode: layermacro
#snapshoturl: http://localhost:8080/?action=snapshot
#gcode_verbose: True
parkhead: True
parkpos: custom
park_custom_pos_x: 150.0
park_custom_pos_y: 280.0
#park_custom_pos_dz: 0.0
park_travel_speed: 600
#park_retract_speed: 15
#park_extrude_speed: 15
#park_retract_distance: 1.0
#park_extrude_distance: 1.0
#hyperlapse_cycle: 30
#autorender: True
#constant_rate_factor: 23
#output_framerate: 30
#pixelformat: yuv420p
#time_format_code: %Y%m%d_%H%M
#extraoutputparams:
#variable_fps: False
#targetlength: 10
#variable_fps_min: 5
#variable_fps_max: 60
#flip_x: False
#flip_y: False
#duplicatelastframe: 0
#previewimage: True
#saveframes: False
#wget_skip_cert_check: False
```

< /Paramètres>
Ces paramètres pourraient ne pas être dans cette section, pour les modifier alors, il faut utiliser la macro G-Code `_TIME`
en lui passant les valeurs souhaitées.

**IMPORTANT**:

L'espace disponible sur l'eMMC de 8 Go est très limité (≃ 512 Mo), il serait judicieux soit 
 - de remplacer l'EMMC par une de taille plus grande (16, 32 Go)
 - faire le ménage dans les paquets installés ( `sudo apt clean` est un bon début :smirk; )
 - monter une clé USB pour servir de stockage et indiquer dans la section [virtual_sdcard] du printer.cfg son point de montage

```
[virtual_sdcard]
path: /mnt/nom-du-point-de-montage
```

Plus d'informations [Moonraker-timelapse](https://github.com/mainsail-crew/moonraker-timelapse)
