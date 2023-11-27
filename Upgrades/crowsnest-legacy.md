# Installation de Crowsnest

L'OS de la carte SKIPR de la Qidi X-Max 3 est une Armbian Buster (datée donc).

Souhaitant remplacer le MJPEG Streamer installé par défaut, et utiliser une solution plus moderne, Mainsail propose Crowsnest. 

KIAUH est installé (et à jour) mais l'option d'installation installe la dernière version de Crowsnest (v4) incompatible avec les versions antérieures à Bullseye.
Il faut donc passer par une installation manuelle qui permet alors de sélectionner une version v3 dite «legacy» sur une distribution Buster.

La [documentation de Mainsail](https://github.com/mainsail-crew/crowsnest/tree/legacy/v3) décrit les étapes à réaliser.

Je ne reprends donc que les lignes de commandes utilisées pour cette installation :
- se connecter en ssh sur la carte en tant qu'utilisateur `mks`
- cloner le dépôt de Crowsnest
  ```
  cd ~
  git clone https://github.com/mainsail-crew/crowsnest.git
  ```
- modifier la branche actuelle par la «legacy» :
  ```
  cd ~/crowsnest
  git fetch
  git checkout legacy/v3
  ```

<details>

  ```
mks@mkspi:~$ git clone https://github.com/mainsail-crew/crowsnest.git
Cloning into 'crowsnest'...
remote: Enumerating objects: 1513, done.
remote: Counting objects: 100% (135/135), done.
remote: Compressing objects: 100% (68/68), done.
remote: Total 1513 (delta 87), reused 81 (delta 66), pack-reused 1378
Receiving objects: 100% (1513/1513), 593.25 KiB | 3.68 MiB/s, done.
Resolving deltas: 100% (911/911), done.
mks@mkspi:~$ cd crowsnest/
mks@mkspi:~/crowsnest$ git fetch
mks@mkspi:~/crowsnest$ git checkout legacy/v3
Branch 'legacy/v3' set up to track remote branch 'legacy/v3' from 'origin'.
Switched to a new branch 'legacy/v3'
  ```

</details>

- lancer l'installation
  ```
  sudo make install
  ```

<details>
  
  ```
mks@mkspi:~/crowsnest$ sudo make install
crowsnest - A webcam daemon for multiple Cams and stream services.

        Ahoi!
        Thank you for installing crowsnest ;)
        This will take a while ...
        Please reboot after installation has finished.

Running apt update first ...
Hit:1 http://deb.debian.org/debian buster InRelease
Hit:2 http://deb.debian.org/debian buster-updates InRelease
Get:3 http://deb.debian.org/debian buster-backports InRelease [51.4 kB]
Get:4 http://security.debian.org buster/updates InRelease [34.8 kB]
Hit:5 http://armbian.hosthatch.com/apt buster InRelease
Get:6 http://security.debian.org buster/updates/main armhf Packages [731 kB]
Get:7 http://security.debian.org buster/updates/main arm64 Packages [728 kB]
Fetched 1,546 kB in 3s (602 kB/s)
Reading package lists...
Installing 'crowsnest' Dependencies ...
Reading package lists...
Building dependency tree...
Reading state information...
build-essential is already the newest version (12.6).
findutils is already the newest version (4.6.0+git+20190209-2).
libjpeg-dev is already the newest version (1:1.5.2-2+deb10u1).
libxcomposite1 is already the newest version (1:0.4.4-2).
libxtst6 is already the newest version (2:1.2.3-1).
libxtst6 set to manually installed.
bsdutils is already the newest version (1:2.33.1-0.1).
curl is already the newest version (7.64.0-4+deb10u7).
ffmpeg is already the newest version (7:4.1.11-0+deb10u1).
The following additional packages will be installed:
  libevent-extra-2.1-6 libevent-openssl-2.1-6 python-iniparse python-six
Suggested packages:
  gettext-base git-daemon-run | git-daemon-sysvinit git-doc git-el git-email git-gui gitk gitweb git-cvs git-mediawiki git-svn
The following NEW packages will be installed:
  crudini libbsd-dev libevent-dev libevent-extra-2.1-6 libevent-openssl-2.1-6 python-iniparse python-six v4l-utils
The following packages will be upgraded:
  git
1 upgraded, 8 newly installed, 0 to remove and 197 not upgraded.
Need to get 6,649 kB of archives.
After this operation, 4,687 kB of additional disk space will be used.
Get:1 http://security.debian.org buster/updates/main arm64 git arm64 1:2.20.1-2+deb10u8 [5,501 kB]
Get:2 http://deb.debian.org/debian buster/main arm64 python-six all 1.12.0-1 [15.7 kB]
Get:3 http://deb.debian.org/debian buster/main arm64 python-iniparse all 0.4-2.2 [21.0 kB]
Get:4 http://deb.debian.org/debian buster/main arm64 crudini arm64 0.7-1 [12.2 kB]
Get:5 http://deb.debian.org/debian buster/main arm64 libbsd-dev arm64 0.9.1-2+deb10u1 [218 kB]
Get:6 http://deb.debian.org/debian buster/main arm64 libevent-extra-2.1-6 arm64 2.1.8-stable-4 [88.5 kB]
Get:7 http://deb.debian.org/debian buster/main arm64 libevent-openssl-2.1-6 arm64 2.1.8-stable-4 [52.4 kB]
Get:8 http://deb.debian.org/debian buster/main arm64 libevent-dev arm64 2.1.8-stable-4 [287 kB]
Get:9 http://deb.debian.org/debian buster/main arm64 v4l-utils arm64 1.16.3-3 [453 kB]
Fetched 6,649 kB in 1s (9,361 kB/s)
Selecting previously unselected package python-six.
(Reading database ... 143827 files and directories currently installed.)
Preparing to unpack .../0-python-six_1.12.0-1_all.deb ...
Unpacking python-six (1.12.0-1) ...
Selecting previously unselected package python-iniparse.
Preparing to unpack .../1-python-iniparse_0.4-2.2_all.deb ...
Unpacking python-iniparse (0.4-2.2) ...
Selecting previously unselected package crudini.
Preparing to unpack .../2-crudini_0.7-1_arm64.deb ...
Unpacking crudini (0.7-1) ...
Preparing to unpack .../3-git_1%3a2.20.1-2+deb10u8_arm64.deb ...
Unpacking git (1:2.20.1-2+deb10u8) over (1:2.20.1-2+deb10u3) ...
Selecting previously unselected package libbsd-dev:arm64.
Preparing to unpack .../4-libbsd-dev_0.9.1-2+deb10u1_arm64.deb ...
Unpacking libbsd-dev:arm64 (0.9.1-2+deb10u1) ...
Selecting previously unselected package libevent-extra-2.1-6:arm64.
Preparing to unpack .../5-libevent-extra-2.1-6_2.1.8-stable-4_arm64.deb ...
Unpacking libevent-extra-2.1-6:arm64 (2.1.8-stable-4) ...
Selecting previously unselected package libevent-openssl-2.1-6:arm64.
Preparing to unpack .../6-libevent-openssl-2.1-6_2.1.8-stable-4_arm64.deb ...
Unpacking libevent-openssl-2.1-6:arm64 (2.1.8-stable-4) ...
Selecting previously unselected package libevent-dev.
Preparing to unpack .../7-libevent-dev_2.1.8-stable-4_arm64.deb ...
Unpacking libevent-dev (2.1.8-stable-4) ...
Selecting previously unselected package v4l-utils.
Preparing to unpack .../8-v4l-utils_1.16.3-3_arm64.deb ...
Unpacking v4l-utils (1.16.3-3) ...
Setting up libevent-extra-2.1-6:arm64 (2.1.8-stable-4) ...
Setting up libevent-openssl-2.1-6:arm64 (2.1.8-stable-4) ...
Setting up v4l-utils (1.16.3-3) ...
Setting up python-six (1.12.0-1) ...
Setting up libevent-dev (2.1.8-stable-4) ...
Setting up git (1:2.20.1-2+deb10u8) ...
Setting up libbsd-dev:arm64 (0.9.1-2+deb10u1) ...
Setting up python-iniparse (0.4-2.2) ...
Setting up crudini (0.7-1) ...
Processing triggers for libc-bin (2.28-10+deb10u1) ...
Processing triggers for man-db (2.8.5-2) ...
Processing triggers for doc-base (0.10.8) ...
Processing 1 added doc-base file...
Installing 'crowsnest' Dependencies ... [OK]
Linking crowsnest ... [OK]
Copying crowsnest.conf ... [OK]
Build dependend Stream Apps ...
Cloning ustreamer repository ...
Cloning into 'bin/ustreamer'...
remote: Enumerating objects: 9378, done.
remote: Counting objects: 100% (497/497), done.
remote: Compressing objects: 100% (108/108), done.
remote: Total 9378 (delta 414), reused 427 (delta 387), pack-reused 8881
Receiving objects: 100% (9378/9378), 5.53 MiB | 3.12 MiB/s, done.
Resolving deltas: 100% (6256/6256), done.
HEAD is now at 61ab2a8 Bump version: 4.12 → 4.13
INFO: ustreamer found.
make ustreamer-bin
make[1]: Entering directory '/home/mks/crowsnest/bin'
make[1]: warning: -j4 forced in makefile: resetting jobserver mode.
Compiling ustreamer without OMX Support.
make -C ustreamer
make[2]: Entering directory '/home/mks/crowsnest/bin/ustreamer'
make apps
make[3]: Entering directory '/home/mks/crowsnest/bin/ustreamer'
make -C src
make[4]: Entering directory '/home/mks/crowsnest/bin/ustreamer/src'
-- CC libs/base64.c
-- CC libs/frame.c
-- CC libs/logging.c
-- CC libs/memsink.c
-- CC libs/options.c
-- CC libs/unjpeg.c
-- CC ustreamer/blank.c
-- CC ustreamer/data/blank_jpeg.c
-- CC ustreamer/data/index_html.c
-- CC ustreamer/device.c
-- CC ustreamer/encoder.c
-- CC ustreamer/encoders/cpu/encoder.c
-- CC ustreamer/encoders/hw/encoder.c
-- CC ustreamer/http/bev.c
-- CC ustreamer/http/mime.c
-- CC ustreamer/http/path.c
-- CC ustreamer/http/server.c
-- CC ustreamer/http/static.c
-- CC ustreamer/http/unix.c
-- CC ustreamer/http/uri.c
-- CC ustreamer/main.c
-- CC ustreamer/options.c
-- CC ustreamer/stream.c
-- CC ustreamer/workers.c
-- CC dump/file.c
-- CC dump/main.c
== LD ustreamer-dump.bin
== LD ustreamer.bin
make[4]: Leaving directory '/home/mks/crowsnest/bin/ustreamer/src'
make[3]: Leaving directory '/home/mks/crowsnest/bin/ustreamer'
make[2]: Leaving directory '/home/mks/crowsnest/bin/ustreamer'
make[1]: Leaving directory '/home/mks/crowsnest/bin'
make rtsp
make[1]: Entering directory '/home/mks/crowsnest/bin'
make[1]: warning: -j4 forced in makefile: resetting jobserver mode.
Download rtsp-simple-server_v0.20.2_linux_arm64v8.tar.gz from https://github.com/aler9/rtsp-simple-server/releases/download/v0.20.2/
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 9379k  100 9379k    0     0  6028k      0  0:00:01  0:00:01 --:--:-- 10.0M
Finished.
make[1]: Leaving directory '/home/mks/crowsnest/bin'
Add User mks to group 'video' ... [SKIPPED]
==> User mks is already in group 'video'
Install crowsnest.service file ... [OK]
Enable crowsnest.service on boot ... [OK]
Install logrotate file ... [OK]

Installation successful.

        To take changes effect, you need to reboot your machine!

Reboot NOW? [y/N]: N

  ```
</details>

- redémarrer le système comme suggéré (répondre y :smirk: )
- après redémarrage, vérifier que le service `crowsnest` est bien démarré
  ```
  systemctl status crowsnest
  ```

## IMPORTANT

Qidi Tech utilise le service **webcamd** exécuté au démarrage du système pour afficher le flux de la caméra.

Ce service utilise mjpeg-streamer pour la diffusion du flux vidéo, la configuration de la caméra utilise le fichier **webcam.txt**.

**Crowsnest** utilise **ustreamer** comme diffuseur de flux vidéo, celui-ci ne peut démarrer car **webcamd** interfère. Il faut :
1. Arrêter le service **webcamd** et le désactiver
   ```
   sudo systemctl stop webcamd
   sudo systemctl diable webcamd
   ```
2. Redémarrer **crowsnest**
   ```
   sudo systemctl restart crowsnest
   ```

### NO SIGNAL

Si au lieu de voir l'affichage de la caméra, **NO SIGNAL** apparait sur un fond noir

Vérifier que dans le fichier **crowsnest.conf**, dans la section [cam xxxx], la ligne **device:** pointe sur le bon périphérique.

Le meilleur moyen de connaitre le nom du périphérique Webcam est d'utiliser un outil fourni par Crowsnest:

```
cd ~/crowsnest
tools/dev-helper.sh -c
```

Le résultat peut être redirigé vers un fichier en ajoutant à la suite de l'option "-c" un **>/tmp/crowsnest-ma-webcam.txt**

<details>

```
mks@mkspi:~/crowsnest$ ./tools/dev-helper.sh -c
crowsnest - dev-helper.sh

v4l2-ctl supported camera(s):

Device /dev/video4:

Symbolic links to /dev/video4:

/dev/v4l/by-id/usb-SYX-230524-J_HD_Camera-video-index0
/dev/v4l/by-path/platform-ff5c0000.usb-usb-0:1.3:1.0-video-index0


Supported formats:

        [0]: 'MJPG' (Motion-JPEG, compressed)
                Size: Discrete 1280x720
                        Interval: Discrete 0.033s (30.000 fps)
                Size: Discrete 1920x1080
                        Interval: Discrete 0.033s (30.000 fps)
                Size: Discrete 640x480
                        Interval: Discrete 0.033s (30.000 fps)
        [1]: 'YUYV' (YUYV 4:2:2)
                Size: Discrete 1280x720
                        Interval: Discrete 0.100s (10.000 fps)
                Size: Discrete 1920x1080
                        Interval: Discrete 0.200s (5.000 fps)
                Size: Discrete 640x480
                        Interval: Discrete 0.033s (30.000 fps)

Supported Controls:


User Controls

                     brightness 0x00980900 (int)    : min=-64 max=64 step=1 default=0 value=0
                       contrast 0x00980901 (int)    : min=0 max=95 step=1 default=0 value=0
                     saturation 0x00980902 (int)    : min=0 max=100 step=1 default=80 value=80
                            hue 0x00980903 (int)    : min=-2000 max=2000 step=1 default=0 value=0
        white_balance_automatic 0x0098090c (bool)   : default=1 value=1
                          gamma 0x00980910 (int)    : min=64 max=300 step=1 default=84 value=84
                           gain 0x00980913 (int)    : min=1 max=8 step=1 default=1 value=1
           power_line_frequency 0x00980918 (menu)   : min=0 max=2 default=1 value=1
                                0: Disabled
                                1: 50 Hz
                                2: 60 Hz
      white_balance_temperature 0x0098091a (int)    : min=2800 max=6500 step=1 default=3980 value=3980 flags=inactive
                      sharpness 0x0098091b (int)    : min=1 max=7 step=1 default=2 value=2
         backlight_compensation 0x0098091c (int)    : min=0 max=128 step=0 default=0 value=0

Camera Controls

                  auto_exposure 0x009a0901 (menu)   : min=0 max=3 default=3 value=3
                                1: Manual Mode
                                3: Aperture Priority Mode
         exposure_time_absolute 0x009a0902 (int)    : min=10 max=626 step=1 default=156 value=156 flags=inactive

Device /dev/video1:

Symbolic links to /dev/video1:

/dev/v4l/by-path/platform-ff390000.rga-video-index0


Supported formats:

        [0]: 'BA24' (32-bit ARGB 8-8-8-8)
        [1]: 'BX24' (32-bit XRGB 8-8-8-8)
        [2]: 'AR24' (32-bit BGRA 8-8-8-8)
        [3]: 'XR24' (32-bit BGRX 8-8-8-8)
        [4]: 'RGB3' (24-bit RGB 8-8-8)
        [5]: 'BGR3' (24-bit BGR 8-8-8)
        [6]: 'AR12' (16-bit ARGB 4-4-4-4)
        [7]: 'AR15' (16-bit ARGB 1-5-5-5)
        [8]: 'RGBP' (16-bit RGB 5-6-5)
        [9]: 'NV21' (Y/CrCb 4:2:0)
        [10]: 'NV61' (Y/CrCb 4:2:2)
        [11]: 'NV12' (Y/CbCr 4:2:0)
        [12]: 'NV16' (Y/CbCr 4:2:2)
        [13]: 'YU12' (Planar YUV 4:2:0)
        [14]: '422P' (Planar YUV 4:2:2)
        [15]: 'YV12' (Planar YVU 4:2:0)

Supported Controls:


User Controls

                horizontal_flip 0x00980914 (bool)   : default=0 value=0
                  vertical_flip 0x00980915 (bool)   : default=0 value=0
                         rotate 0x00980922 (int)    : min=0 max=270 step=90 default=0 value=0 flags=modify-layout
               background_color 0x00980923 (int)    : min=0 max=16777215 step=1 default=0 value=0

Device /dev/video0:

Symbolic links to /dev/video0:

/dev/v4l/by-path/platform-ff3a0000.iep-video-index0


Supported formats:

        [0]: 'NV12' (Y/CbCr 4:2:0)
                Size: Stepwise 320x240 - 1920x1088 with step 16/16
        [1]: 'NV21' (Y/CrCb 4:2:0)
                Size: Stepwise 320x240 - 1920x1088 with step 16/16
        [2]: 'NV16' (Y/CbCr 4:2:2)
                Size: Stepwise 320x240 - 1920x1088 with step 16/16
        [3]: 'NV61' (Y/CrCb 4:2:2)
                Size: Stepwise 320x240 - 1920x1088 with step 16/16
        [4]: 'YU12' (Planar YUV 4:2:0)
                Size: Stepwise 320x240 - 1920x1088 with step 16/16
        [5]: '422P' (Planar YUV 4:2:2)
                Size: Stepwise 320x240 - 1920x1088 with step 16/16
```

</details>

Les informations affichées permettent d'obtenir :
- le périphérique
  - **/dev/video4** (lien symbolique, on peut préférer utiliser le périphérique «direct» (/dev/v4l/by-id ou /dev/v4l/by-path) :
    - /dev/v4l/by-id/usb-SYX-230524-J_HD_Camera-video-index0
    - /dev/v4l/by-path/platform-ff5c0000.usb-usb-0:1.3:1.0-video-index0
- les résolutions possibles
- les contrôles possibles (via v4l-utils)

## Quelques modifications «cosmétiques»

L'installation a placé le fichier `crowsnest.conf` dans le répertoire `~/printer_data/config`, les journaux dans `~/printer_data/logs`.

>  Qidi utilise le répertoire **~/klipper_config** pour les fichiers de configuration et **~/klipper_logs** pour les journaux.

- Solution la plus facile (et rapide)
  - Créer un lien symbolique pour ces fichiers :
  ```
  ln -sf /home/mks/printer_data/config/crowsnest.conf /home/mks/klipper_config/crowsnest.conf
  ln -sf /home/mks/printer_data/logs/crowsnest.log /home/mks/klipper_logs/crowsnest.log
  ```
    
- Autre solution (demande de mettre un peu plus les mains dans le cambouis) 
  - Copier le fichier **crowsnest.conf** dans le répertoire **~/klipper_config**
  - Éditer le fichier **~/printer_data/systemd/crowsnest.env**
  - Remplacer le chemin d'accès dans la variable **CROWSNEST_ARGS**
  ```
  -c /home/mks/printer_data/config/crowsnest.conf

    par

  -c /home/mks/klipper_config/crowsnest.conf
  ```
  - Éditer **crowsnest.conf**, modifier l'emplacement de stockage des journaux (***log_path: ~/klipper_logs/crowsnest.log***)
  > En procédant ainsi il faut également modifier le fichier de rotation des journaux (**logrotate**) => ***/etc/logrotate.d/crowsnest***
  - redémarrer le service : `sudo systemctl restart crowsnest`

<details>

  ```bash
mks@mkspi:~$ sudo systemctl status crowsnest
● crowsnest.service - crowsnest - Multi Webcam/Streamer Control Deamon
   Loaded: loaded (/etc/systemd/system/crowsnest.service; enabled; vendor preset: enabled)
   Active: active (running) since Tue 2023-11-14 17:43:11 CET; 5s ago
     Docs: https://github.com/mainsail-crew/crowsnest
 Main PID: 8162 (crowsnest)
    Tasks: 6 (limit: 998)
   Memory: 4.6M
   CGroup: /system.slice/crowsnest.service
           ├─8162 /bin/bash /usr/local/bin/crowsnest -c /home/mks/klipper_config/crowsnest.conf
           ├─8907 /bin/bash /usr/local/bin/crowsnest -c /home/mks/klipper_config/crowsnest.conf
           ├─8908 sleep 2
           ├─8928 /bin/bash /usr/local/bin/crowsnest -c /home/mks/klipper_config/crowsnest.conf
           ├─8929 /usr/bin/python /usr/bin/crudini --get /home/mks/klipper_config/crowsnest.conf crowsnest no_proxy
           └─8930 sed s/\#.*//;s/[[:space:]]*$//

Nov 14 17:43:14 mkspi crowsnest[8162]: [11/14/23 17:43:14] crowsnest:                 3: Aperture Priority Mode
Nov 14 17:43:14 mkspi crowsnest[8162]: [11/14/23 17:43:14] crowsnest:                 exposure_time_absolute 0x009a0902 (int) : min=10 ma
Nov 14 17:43:14 mkspi crowsnest[8826]:                 exposure_time_absolute 0x009a0902 (int)    : min=10 max=626 step=1 default=156 val
Nov 14 17:43:14 mkspi crowsnest[8162]: [11/14/23 17:43:14] crowsnest: INFO: No usable CSI Devices found.
Nov 14 17:43:14 mkspi crowsnest[8838]: INFO: No usable CSI Devices found.
Nov 14 17:43:15 mkspi crowsnest[8162]: [11/14/23 17:43:15] crowsnest: V4L2 Control: No parameters set for [cam 1]. Skipped.
Nov 14 17:43:15 mkspi crowsnest[8858]: V4L2 Control: No parameters set for [cam 1]. Skipped.
Nov 14 17:43:15 mkspi crowsnest[8162]: [11/14/23 17:43:15] crowsnest: Try to start configured Cams / Services...
Nov 14 17:43:15 mkspi crowsnest[8881]: Try to start configured Cams / Services...
Nov 14 17:43:16 mkspi crowsnest[8162]: [11/14/23 17:43:16] crowsnest: INFO: Configuration of Section [cam 1] looks good. Continue...
```

</details>

On peut ajouter au fichier `moonraker.conf` la section suivante pour gérer les mises à jour :

  ```
  [update_manager crowsnest]
  type: git_repo
  path: ~/crowsnest
  origin: https://github.com/mainsail-crew/crowsnest.git
  primary_branch: legacy/v3
  install_script: tools/install.sh
  ```

Enjoy !

:smiley:
