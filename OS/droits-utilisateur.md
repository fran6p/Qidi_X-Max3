# proprio / droits ficher gcode téléversés :

mks@mkspi:~$ ls -l gcode_files/
total 49596
-rwxrwxrwx 1 root root  2433270 Dec 11  2022  3DBenchy.gcode
-rwxrwxrwx 1 root root 21858615 Dec 11  2022 '52mm Filament Spool Holder.gcode'
-rwxrwxrwx 1 root root  4929546 Dec 11  2022  bunny.gcode
-rw-r--r-- 1 mks  mks    871724 Aug 15 23:56 'logitech270-cam mount.gcode'
-rw-r--r-- 1 mks  mks   4133503 Aug 15 21:26  NBC-3D-Test.gcode
-rwxrwxrwx 1 root root  1229198 Dec 11  2022  QIDI.gcode
-rw-r--r-- 1 mks  mks   1806246 Aug 15 23:56  side_spool_holder-xmax3-drybox-45deg-angle.gcode
-rw-r--r-- 1 mks  mks   2185786 Aug 15 21:26  Voron_Design_Cube_v7.gcode
-rwxrwxrwx 1 root root  2540118 Dec 11  2022  wildrosebuilds_puzzlecube.gcode
-rwxrwxrwx 1 root root  2408699 Dec 11  2022  X.gcode
-rwxrwxrwx 1 root root  6363785 Dec 11  2022  yafic_v2_rounded.gcode
mks@mkspi:~$ sudo chown mks:mks gcode_files/*
[sudo] password for mks:
mks@mkspi:~$ ls -l gcode_files/
total 49596
-rwxrwxrwx 1 mks mks  2433270 Dec 11  2022  3DBenchy.gcode
-rwxrwxrwx 1 mks mks 21858615 Dec 11  2022 '52mm Filament Spool Holder.gcode'
-rwxrwxrwx 1 mks mks  4929546 Dec 11  2022  bunny.gcode
-rw-r--r-- 1 mks mks   871724 Aug 15 23:56 'logitech270-cam mount.gcode'
-rw-r--r-- 1 mks mks  4133503 Aug 15 21:26  NBC-3D-Test.gcode
-rwxrwxrwx 1 mks mks  1229198 Dec 11  2022  QIDI.gcode
-rw-r--r-- 1 mks mks  1806246 Aug 15 23:56  side_spool_holder-xmax3-drybox-45deg-angle.gcode
-rw-r--r-- 1 mks mks  2185786 Aug 15 21:26  Voron_Design_Cube_v7.gcode
-rwxrwxrwx 1 mks mks  2540118 Dec 11  2022  wildrosebuilds_puzzlecube.gcode
-rwxrwxrwx 1 mks mks  2408699 Dec 11  2022  X.gcode
-rwxrwxrwx 1 mks mks  6363785 Dec 11  2022  yafic_v2_rounded.gcode
mks@mkspi:~$ chmod -x gcode_files/*
mks@mkspi:~$ ls -l gcode_files/
total 49596
-rw-rw-rw- 1 mks mks  2433270 Dec 11  2022  3DBenchy.gcode
-rw-rw-rw- 1 mks mks 21858615 Dec 11  2022 '52mm Filament Spool Holder.gcode'
-rw-rw-rw- 1 mks mks  4929546 Dec 11  2022  bunny.gcode
-rw-r--r-- 1 mks mks   871724 Aug 15 23:56 'logitech270-cam mount.gcode'
-rw-r--r-- 1 mks mks  4133503 Aug 15 21:26  NBC-3D-Test.gcode
-rw-rw-rw- 1 mks mks  1229198 Dec 11  2022  QIDI.gcode
-rw-r--r-- 1 mks mks  1806246 Aug 15 23:56  side_spool_holder-xmax3-drybox-45deg-angle.gcode
-rw-r--r-- 1 mks mks  2185786 Aug 15 21:26  Voron_Design_Cube_v7.gcode
-rw-rw-rw- 1 mks mks  2540118 Dec 11  2022  wildrosebuilds_puzzlecube.gcode
-rw-rw-rw- 1 mks mks  2408699 Dec 11  2022  X.gcode
-rw-rw-rw- 1 mks mks  6363785 Dec 11  2022  yafic_v2_rounded.gcode
mks@mkspi:~$ chmod go-w gcode_files/*
mks@mkspi:~$ ls -l gcode_files/
total 49596
-rw-r--r-- 1 mks mks  2433270 Dec 11  2022  3DBenchy.gcode
-rw-r--r-- 1 mks mks 21858615 Dec 11  2022 '52mm Filament Spool Holder.gcode'
-rw-r--r-- 1 mks mks  4929546 Dec 11  2022  bunny.gcode
-rw-r--r-- 1 mks mks   871724 Aug 15 23:56 'logitech270-cam mount.gcode'
-rw-r--r-- 1 mks mks  4133503 Aug 15 21:26  NBC-3D-Test.gcode
-rw-r--r-- 1 mks mks  1229198 Dec 11  2022  QIDI.gcode
-rw-r--r-- 1 mks mks  1806246 Aug 15 23:56  side_spool_holder-xmax3-drybox-45deg-angle.gcode
-rw-r--r-- 1 mks mks  2185786 Aug 15 21:26  Voron_Design_Cube_v7.gcode
-rw-r--r-- 1 mks mks  2540118 Dec 11  2022  wildrosebuilds_puzzlecube.gcode
-rw-r--r-- 1 mks mks  2408699 Dec 11  2022  X.gcode
-rw-r--r-- 1 mks mks  6363785 Dec 11  2022  yafic_v2_rounded.gcode
mks@mkspi:~$

############################################################################################
mks@mkspi:~$ ls -al klipper_config/
total 80
drwxr-xr-x  2 mks  mks   4096 Aug 16 01:17 .
drwxr-xr-x 32 mks  mks   4096 Aug 16 02:20 ..
-rwxrwxrwx  1 root root 14140 Dec 10  2022 Adaptive_Mesh.cfg
-rw-r--r--  1 mks  mks   2126 Jul 25  2022 fluidd.cfg
-rw-r--r--  1 mks  mks    123 Jul 25  2022 KlipperScreen.conf
-rw-r--r--  1 mks  mks   3978 Aug 16 01:17 MKS_THR.cfg
-rw-r--r--  1 mks  mks   1161 Aug 15 09:18 moonraker.conf
-rw-r--r--  1 mks  mks    610 Aug 15 09:18 .moonraker.conf.bkp
-rw-r--r--  1 mks  mks    816 Aug 15 07:26 power_macros.cfg
-rw-r--r--  1 mks  mks  25015 Aug 16 02:39 printer.cfg
-rw-r--r--  1 mks  mks   2607 Jul 26  2022 webcam.txt
mks@mkspi:~$ sudo chown mks:mks klipper_config/Adaptive_Mesh.cfg
mks@mkspi:~$ chmod a-x,go-w klipper_config/Adaptive_Mesh.cfg
mks@mkspi:~$ ls -al klipper_config/
total 80
drwxr-xr-x  2 mks mks  4096 Aug 16 01:17 .
drwxr-xr-x 32 mks mks  4096 Aug 16 02:20 ..
-rw-r--r--  1 mks mks 14140 Dec 10  2022 Adaptive_Mesh.cfg
-rw-r--r--  1 mks mks  2126 Jul 25  2022 fluidd.cfg
-rw-r--r--  1 mks mks   123 Jul 25  2022 KlipperScreen.conf
-rw-r--r--  1 mks mks  3978 Aug 16 01:17 MKS_THR.cfg
-rw-r--r--  1 mks mks  1161 Aug 15 09:18 moonraker.conf
-rw-r--r--  1 mks mks   610 Aug 15 09:18 .moonraker.conf.bkp
-rw-r--r--  1 mks mks   816 Aug 15 07:26 power_macros.cfg
-rw-r--r--  1 mks mks 25015 Aug 16 02:39 printer.cfg
-rw-r--r--  1 mks mks  2607 Jul 26  2022 webcam.txt
mks@mkspi:~$
