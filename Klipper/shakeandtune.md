## Installation

Se connecter en ssh sur l'imprimante (utilisateur: **mks**, mot de passe: ***makerbase***). Ensuite, il suffit de suivre les indications du dépôt:

1. Installation

```
wget -O - https://raw.githubusercontent.com/Frix-x/klippain-shaketune/main/install.sh | bash
```

  1.1 Qidi utilisant le répertoire ~/klipper_config pour les fichiers de configurations, ajouter un lien symbolique pour que le répertoire
de configurations de Shake And Tune soit éditable via Fluidd (Mainsail) :

```
ln -sf /home/mks/klippain_shaketune/K-ShakeTune/ /home/mks/klipper_config/K-ShakeTune
```

<details>

```
mks@mkspi:~$ wget -O - https://raw.githubusercontent.com/Frix-x/klippain-shaketune/main/install.sh | bash
--2023-11-28 17:17:05--  https://raw.githubusercontent.com/Frix-x/klippain-shaketune/main/install.sh
Resolving raw.githubusercontent.com (raw.githubusercontent.com)... 185.199.108.133, 185.199.109.133, 185.199.110.133, ...
Connecting to raw.githubusercontent.com (raw.githubusercontent.com)|185.199.108.133|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 2685 (2.6K) [text/plain]
Saving to: ‘STDOUT’

-                                  100%[=============================================================>]   2.62K  --.-KB/s    in 0s

2023-11-28 17:17:05 (13.8 MB/s) - written to stdout [2685/2685]


=============================================
- Klippain Shake&Tune module install script -
=============================================

[PRE-CHECK] Klipper service found! Continuing...

[DOWNLOAD] Downloading Klippain Shake&Tune module repository...
Cloning into 'klippain_shaketune'...
remote: Enumerating objects: 258, done.
remote: Counting objects: 100% (31/31), done.
remote: Compressing objects: 100% (28/28), done.
remote: Total 258 (delta 9), reused 8 (delta 3), pack-reused 227
Receiving objects: 100% (258/258), 20.87 MiB | 1.60 MiB/s, done.
Resolving deltas: 100% (103/103), done.
[DOWNLOAD] Download complete!

[INSTALL] Linking scripts to your config directory...
[INSTALL] gcode_shell_command.py Klipper extension is already installed. Continuing...

[POST-INSTALL] Restarting Klipper...
mks@mkspi:~$
mks@mkspi:~$ ln -sf /home/mks/klippain_shaketune/K-ShakeTune/ /home/mks/klipper_config/K-ShakeTune
mks@mkspi:~$ ls -l klipper_config
total 96
-rw-r--r-- 1 mks  mks  14140 Aug 23 07:20 Adaptive_Mesh.cfg
drwxr-xr-x 2 mks  mks   4096 Sep  2 18:51 adxl_results
drwxr-xr-x 2 mks  mks   4096 Nov 27 10:16 backups
lrwxrwxrwx 1 mks  mks     34 Aug 21 12:39 client.cfg -> /home/mks/fluidd-config/client.cfg
-rw-r--r-- 1 mks  mks    495 Nov 27 14:59 config.mksini
-rw-r--r-- 1 root root   441 Aug 23 07:20 config.mksini.bak
-rw-r--r-- 1 mks  mks   1926 Nov 26 15:02 crowsnest.conf
-rw-r--r-- 1 mks  mks    123 Jul 25  2022 KlipperScreen.conf
lrwxrwxrwx 1 mks  mks     41 Nov 28 18:03 K-ShakeTune -> /home/mks/klippain_shaketune/K-ShakeTune/
drwxr-xr-x 3 mks  mks   4096 Nov 28 16:51 macros
-rw-r--r-- 1 mks  mks   3978 Nov 27 18:17 MKS_THR.cfg
-rw-r--r-- 1 mks  mks   2212 Nov 28 17:57 moonraker.conf
-rw-r--r-- 1 mks  mks   1807 Nov 28 15:23 octoeverywhere.conf
-rw-r--r-- 1 mks  mks    554 Nov 13 16:27 octoeverywhere-system.cfg
-rw-r--r-- 1 mks  mks  23066 Nov 28 18:04 printer.cfg
drwxr-xr-x 2 mks  mks   4096 Nov 28 16:52 scripts
lrwxrwxrwx 1 mks  mks     57 Aug 21 11:49 timelapse.cfg -> /home/mks/moonraker-timelapse/klipper_macro/timelapse.cfg
-rw-r--r-- 1 mks  mks     70 Nov 28 18:04 variables.cfg
-rw-r--r-- 1 mks  mks   2608 Nov 26 15:02 webcam.txt
mks@mkspi:~$


```
  
</details>

2. Compléter le fichier printer.cfg en ajoutant l'inclusion «qui va bien» :

```
[include K-ShakeTune/*.cfg]
```

3. (Facultatif) Compléter le fichier `moonraker.conf` pour permettre les mises à jour :

```
[update_manager Klippain-ShakeTune]
type: git_repo
path: ~/klippain_shaketune
channel: beta
origin: https://github.com/Frix-x/klippain-shaketune.git
primary_branch: main
managed_services: klipper
install_script: install.sh
```

## Utilisation

Mettre l'imprimante à l'origine (`G28` ), puis invoquer l'une des macros suivantes en fonction des besoins :

- **BELTS_SHAPER_CALIBRATION**
  pour les graphiques de résonance des courroies
  => pour vérifier la tension des courroies et le comportement des trajectoires différentielles des courroies.
- **AXES_SHAPER_CALIBRATION**
  pour les graphes de mise en forme d'entrée (input shaping)
  => afin d'atténuer le ringing/ghosting en réglant le système de mise en forme d'entrée de Klipper.
- **VIBRATIONS_CALIBRATION**
  pour les graphiques de vibration de la machine
  => afin d'optimiser les profils de vitesse des trancheurs.
- **EXCITATE_AXIS_AT_FREQ**
  pour maintenir une fréquence d'excitation spécifique
  => pour inspecter et trouver ce qui résonne.

Pour plus d'informations sur l'utilisation des macros et les graphiques générés, se reporter à la [documentation du module K-Shake&Tune](https://github.com/Frix-x/klippain-shaketune/tree/main/docs).
