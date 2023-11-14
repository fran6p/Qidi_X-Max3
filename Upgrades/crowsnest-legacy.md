# Installation de Crowsnest

L'OS de la carte SKIPR de la Qidi X-Max 3 est une Armbian Buster (datée donc).

Souhaitant remplacer le MJPEG Streamer installé par défaut, et utiliser une solution plus moderne, Mainsail propose Crowsnest. 

KIAUH est installé (et à jour) mais l'option d'installation installe la dernière version de Crowsnest (v4) incompatible avec les versions antérieures à Bullseye.
Il faut donc passer par une installation manuelle qui permet alors de sélectionner une version v3 dite «legacy» sur une distribution Buster.

La [documentation de Mainsail](https://crowsnest.mainsail.xyz/faq/use-legacy-branch-on-buster) décrit les étapes à réaliser.

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
