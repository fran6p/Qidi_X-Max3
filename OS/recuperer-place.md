L'image système «Armbian» installée est basée sur une version «Desktop».

Certains paquets (packages) installés sont inutiles et occupent de la place qui pourrait servir à stocker plus de gcodes ou à installer
des compléments pour Klipper (OctoEverywhere ou Obico, gestionnaires de macros, …).

Quelle place occupe les paquets installés ?

```
dpkg-query --show --showformat='${Package;-50}\t${Installed-Size}\n' `aptitude --display-format '%p' search '?installed!?automatic'` | sort -k 2 -n | grep -v deinstall | awk '{printf "%.3f MB \t %s\n", $2/(1024), $1}' >/tmp/largest-installed-packages.txt
```

Les paquets listés dans l'ordre de poids croissant : 
<details>
0.000 MB 	 armbian-config

0.000 MB 	 armbian-zsh

0.000 MB 	 makerbase-client

0.001 MB 	 armbian-bsp-cli-mkspi

0.001 MB 	 armbian-buster-desktop-xfce

0.001 MB 	 armbian-firmware

0.001 MB 	 linux-u-boot-mkspi-edge

0.008 MB 	 printer-driver-all

0.010 MB 	 libboost-all-dev

0.015 MB 	 python2-dev

0.016 MB 	 xfce4

0.017 MB 	 python3-dev

0.020 MB 	 build-essential

0.020 MB 	 laptop-detect

0.021 MB 	 init

0.021 MB 	 wireless-regdb

0.023 MB 	 libu2f-udev

0.026 MB 	 fonts-guru

0.029 MB 	 libsemanage-common

0.029 MB 	 virtualenv

0.030 MB 	 libestr0

0.031 MB 	 fake-hwclock

0.032 MB 	 libaudit-common

0.032 MB 	 libproxy1-plugin-networkmanager

0.033 MB 	 libxdamage1

0.033 MB 	 xbacklight

0.034 MB 	 libxcomposite1

0.038 MB 	 libxau6

0.038 MB 	 libxinerama1

0.039 MB 	 fonts-ubuntu-font-family-console

0.039 MB 	 ttf-ubuntu-font-family

0.040 MB 	 libkeyutils1

0.040 MB 	 libnotify-bin

0.040 MB 	 vlan

0.040 MB 	 xtermset

0.041 MB 	 libmnl0

0.041 MB 	 libnpth0

0.042 MB 	 libcap-ng0

0.043 MB 	 libwmf0.2-7-gtk

0.043 MB 	 netbase

0.044 MB 	 gcc

0.045 MB 	 hostname

0.047 MB 	 ifenslave

0.047 MB 	 libcap2

0.048 MB 	 libatk-adaptor

0.048 MB 	 lsb-base

0.048 MB 	 toilet

0.050 MB 	 gstreamer1.0-packagekit

0.050 MB 	 iperf3

0.050 MB 	 iputils-arping

0.050 MB 	 libattr1

0.050 MB 	 libffi6

0.050 MB 	 xwallpaper

0.051 MB 	 libxfixes3

0.052 MB 	 libargon2-1

0.052 MB 	 libfontenc1

0.052 MB 	 libxdmcp6

0.054 MB 	 liblocale-gettext-perl

0.055 MB 	 librsvg2-common

0.055 MB 	 sysfsutils

0.055 MB 	 xserver-xorg-video-fbdev

0.056 MB 	 stress

0.058 MB 	 libnl-genl-3-dev

0.061 MB 	 sensible-utils

0.062 MB 	 evtest

0.062 MB 	 libfastjson4

0.063 MB 	 libacl1

0.063 MB 	 nocache

0.064 MB 	 libxrender1

0.065 MB 	 libdebconfclient0

0.066 MB 	 inputattach

0.067 MB 	 libgtk2.0-bin

0.067 MB 	 libjpeg-dev

0.068 MB 	 libfont-afm-perl

0.068 MB 	 libjson-c3

0.068 MB 	 whiptail

0.069 MB 	 libgsettings-qt1

0.069 MB 	 xtermcontrol

0.070 MB 	 stm32flash

0.071 MB 	 libjbig0

0.071 MB 	 python3-libgpiod

0.072 MB 	 libdatrie1

0.073 MB 	 haveged

0.073 MB 	 libproxy1-plugin-gsettings

0.073 MB 	 libxcursor1

0.073 MB 	 qrencode

0.076 MB 	 libxrandr2

0.080 MB 	 linux-base

0.080 MB 	 update-inetd

0.082 MB 	 xinit

0.084 MB 	 fping

0.086 MB 	 libcom-err2

0.087 MB 	 readline-common

0.088 MB 	 libthai0

0.089 MB 	 libcap2-bin

0.089 MB 	 pavumeter

0.089 MB 	 profile-sync-daemon

0.092 MB 	 netcat-openbsd

0.093 MB 	 libgcc1

0.094 MB 	 xinput

0.095 MB 	 libsasl2-modules-db

0.096 MB 	 anacron

0.096 MB 	 nginx

0.098 MB 	 iotop

0.098 MB 	 iputils-ping

0.098 MB 	 libss2

0.099 MB 	 jq

0.099 MB 	 usb-modeswitch-data

0.102 MB 	 bridge-utils

0.102 MB 	 libbz2-1.0

0.102 MB 	 libtasn1-6

0.102 MB 	 libwrap0-dev

0.103 MB 	 debconf-utils

0.104 MB 	 mmc-utils

0.104 MB 	 libavahi-common3

0.104 MB 	 libproc-processtable-perl

0.106 MB 	 xorg-docs-core

0.107 MB 	 libpangocairo-1.0-0

0.108 MB 	 gtk2-engines-pixbuf

0.108 MB 	 initramfs-tools

0.110 MB 	 avahi-autoipd

0.110 MB 	 libassuan0

0.110 MB 	 libldap-common

0.111 MB 	 cups-bsd

0.113 MB 	 libip4tc0

0.113 MB 	 libxext6

0.114 MB 	 dfu-util

0.114 MB 	 pinentry-curses

0.115 MB 	 xdotool

0.116 MB 	 libuuid1

0.116 MB 	 libxcb-shm0

0.116 MB 	 sysvinit-utils

0.118 MB 	 fonts-kacst-one

0.118 MB 	 libavahi-client3

0.120 MB 	 matchbox-keyboard

0.121 MB 	 libhavege1

0.121 MB 	 libkmod2

0.122 MB 	 libdigest-sha-perl

0.122 MB 	 libusb-1.0-0

0.122 MB 	 systemd-sysv

0.123 MB 	 libklibc

0.125 MB 	 pv

0.126 MB 	 liblz4-1

0.129 MB 	 libxi6

0.130 MB 	 fonts-guru-extra

0.130 MB 	 init-system-helpers

0.130 MB 	 mesa-utils

0.130 MB 	 pasystray

0.131 MB 	 rfkill

0.134 MB 	 python3-virtualenv

0.135 MB 	 gtk-update-icon-cache

0.135 MB 	 keyutils

0.135 MB 	 logrotate

0.138 MB 	 libxtables12

0.141 MB 	 libpangoft2-1.0-0

0.142 MB 	 usb-modeswitch

0.144 MB 	 brltty-x11

0.146 MB 	 pamix

0.148 MB 	 liblognorm5

0.148 MB 	 sunxi-tools

0.149 MB 	 dbus-x11

0.153 MB 	 libaudit1

0.156 MB 	 libapparmor1

0.158 MB 	 libfontembed1

0.158 MB 	 spice-vdagent

0.158 MB 	 zlib1g

0.161 MB 	 libkrb5support0

0.162 MB 	 cpufrequtils

0.162 MB 	 libxcb-render0

0.163 MB 	 f3

0.163 MB 	 libgpg-error0

0.165 MB 	 gdebi

0.166 MB 	 libgraphite2-3

0.167 MB 	 libfribidi0

0.174 MB 	 libselinux1

0.174 MB 	 mawk

0.175 MB 	 libbsd0

0.177 MB 	 bzip2

0.177 MB 	 liblmdb-dev

0.180 MB 	 libsasl2-2

0.183 MB 	 pkg-config

0.184 MB 	 ucf

0.187 MB 	 resolvconf

0.188 MB 	 libnss-myhostname

0.190 MB 	 libatk1.0-0

0.192 MB 	 gnome-orca

0.203 MB 	 initramfs-tools-core

0.205 MB 	 imagemagick

0.207 MB 	 ghostscript-x

0.209 MB 	 debianutils

0.211 MB 	 ifupdown

0.215 MB 	 dash

0.217 MB 	 libpopt0

0.218 MB 	 policykit-1

0.221 MB 	 libpam-modules-bin

0.223 MB 	 base-passwd

0.224 MB 	 bc

0.224 MB 	 dosfstools

0.224 MB 	 kmod

0.226 MB 	 pulseaudio-module-bluetooth

0.229 MB 	 libusb-dev

0.229 MB 	 debian-archive-keyring

0.229 MB 	 gzip

0.229 MB 	 libksba8

0.230 MB 	 bluez-cups

0.230 MB 	 cifs-utils

0.230 MB 	 libpam0g

0.232 MB 	 xserver-xorg

0.235 MB 	 libhogweed4

0.237 MB 	 fbset

0.242 MB 	 gcc-8-base

0.244 MB 	 libcrack2

0.245 MB 	 hdparm

0.245 MB 	 pavucontrol-qt

0.247 MB 	 iw

0.249 MB 	 cron

0.249 MB 	 liblzma5

0.249 MB 	 libudev1

0.251 MB 	 dmsetup

0.251 MB 	 gtk2-engines-murrine

0.251 MB 	 html2text

0.253 MB 	 htop

0.262 MB 	 less

0.269 MB 	 i2c-tools

0.270 MB 	 libidn2-0

0.271 MB 	 libusb-1.0-0-dev

0.271 MB 	 netplan.io

0.271 MB 	 parted

0.274 MB 	 bsdutils

0.274 MB 	 wireless-tools

0.275 MB 	 libxcb1

0.286 MB 	 libsemanage1

0.292 MB 	 unattended-upgrades

0.295 MB 	 libidn11

0.295 MB 	 libseccomp2

0.297 MB 	 usbutils

0.300 MB 	 libjpeg62-turbo

0.300 MB 	 wireguard-tools

0.302 MB 	 libk5crypto3

0.305 MB 	 expect

0.307 MB 	 libsmartcols1

0.308 MB 	 caffeine

0.326 MB 	 libcroco3

0.332 MB 	 base-files

0.333 MB 	 libffi-dev

0.334 MB 	 libfuse2

0.341 MB 	 libpam-gnome-keyring

0.349 MB 	 xdg-user-dirs-gtk

0.356 MB 	 software-properties-gtk

0.359 MB 	 doc-base

0.359 MB 	 ncurses-base

0.361 MB 	 libnewt0.52

0.362 MB 	 xdg-user-dirs

0.370 MB 	 dhcpcd5

0.371 MB 	 libnettle6

0.372 MB 	 ethtool

0.377 MB 	 libncursesw6

0.379 MB 	 libpam-systemd

0.388 MB 	 curl

0.389 MB 	 libopenjp2-7

0.389 MB 	 mount

0.391 MB 	 libreadline7

0.393 MB 	 ca-certificates

0.394 MB 	 klibc-utils

0.395 MB 	 libpango-1.0-0

0.396 MB 	 xfonts-utils

0.401 MB 	 libwebp6

0.404 MB 	 fonts-opensymbol

0.406 MB 	 libgssapi-krb5-2

0.406 MB 	 libv4l-dev

0.407 MB 	 f2fs-tools

0.410 MB 	 libexpat1

0.411 MB 	 console-setup

0.411 MB 	 libcryptsetup12

0.415 MB 	 zlib1g-dev

0.417 MB 	 libpng16-16

0.422 MB 	 libblkid1

0.428 MB 	 lxtask

0.431 MB 	 fontconfig-config

0.431 MB 	 hicolor-icon-theme

0.444 MB 	 libgail-common

0.446 MB 	 software-properties-common

0.456 MB 	 xfonts-scalable

0.464 MB 	 libext2fs2

0.465 MB 	 libapt-inst2.0

0.467 MB 	 libdbus-1-3

0.467 MB 	 lsof

0.468 MB 	 device-tree-compiler

0.469 MB 	 cups-client

0.470 MB 	 libdevmapper1.02.1

0.472 MB 	 fdisk

0.472 MB 	 libmount1

0.481 MB 	 x11-xserver-utils

0.482 MB 	 chrony

0.488 MB 	 hplip

0.508 MB 	 debconf

0.509 MB 	 libtinfo6

0.510 MB 	 libldap-2.4-2

0.513 MB 	 libfontconfig1

0.513 MB 	 libgmp10

0.515 MB 	 libgdk-pixbuf2.0-0

0.518 MB 	 unzip

0.530 MB 	 fontconfig

0.533 MB 	 libfdisk1

0.542 MB 	 u-boot-tools

0.559 MB 	 hunspell-en-us

0.561 MB 	 libzstd1

0.562 MB 	 ncurses-bin

0.563 MB 	 cracklib-runtime

0.564 MB 	 dbus

0.568 MB 	 viewnior

0.572 MB 	 redshift

0.584 MB 	 psmisc

0.587 MB 	 gpg-wks-server

0.587 MB 	 libnl-3-dev

0.591 MB 	 libpcre3

0.599 MB 	 libthai-data

0.600 MB 	 gpg-wks-client

0.603 MB 	 zip

0.610 MB 	 libtiff5

0.623 MB 	 libsodium-dev

0.637 MB 	 libsepol1

0.642 MB 	 foomatic-db-compressed-ppds

0.652 MB 	 libisc-export1100

0.652 MB 	 xfonts-encodings

0.661 MB 	 isc-dhcp-client

0.670 MB 	 dnsutils

0.671 MB 	 iozone3

0.673 MB 	 python3-apt

0.682 MB 	 python3-distutils

0.683 MB 	 mousetweaks

0.689 MB 	 libpixman-1-0

0.707 MB 	 gnupg

0.708 MB 	 lshw

0.711 MB 	 libcups2

0.715 MB 	 figlet

0.722 MB 	 gpgconf

0.724 MB 	 rsync

0.738 MB 	 libsystemd0

0.740 MB 	 dictionaries-common

0.752 MB 	 libavahi-common-data

0.776 MB 	 libfreetype6

0.789 MB 	 xfce4-notifyd

0.798 MB 	 lightdm

0.814 MB 	 gpgv

0.829 MB 	 adduser

0.842 MB 	 libpam-modules

0.850 MB 	 bluez-tools

0.854 MB 	 thunar-volman

0.854 MB 	 sed

0.878 MB 	 gpgsm

0.903 MB 	 xfce4-screenshooter

0.906 MB 	 evince

0.911 MB 	 pavucontrol

0.914 MB 	 libelf1

0.929 MB 	 net-tools

0.936 MB 	 gnome-font-viewer

0.936 MB 	 libgcrypt20

0.942 MB 	 libwebsocketpp-dev

0.955 MB 	 fonts-kacst

0.967 MB 	 grep

0.970 MB 	 cpio

0.972 MB 	 libdbus-1-dev

0.972 MB 	 screen

0.979 MB 	 gir1.2-gtk-3.0

0.999 MB 	 system-config-printer

1.028 MB 	 hostapd

1.031 MB 	 cups

1.047 MB 	 libpam-runtime

1.058 MB 	 apt-utils

1.074 MB 	 avrdude

1.084 MB 	 libkrb5-3

1.134 MB 	 dialog

1.185 MB 	 gpg-agent

1.187 MB 	 libatk1.0-data

1.188 MB 	 pciutils

1.192 MB 	 dirmngr

1.212 MB 	 flex

1.242 MB 	 libsqlite3-0

1.275 MB 	 dos2unix

1.282 MB 	 gstreamer1.0-plugins-base-apps

1.291 MB 	 slick-greeter

1.312 MB 	 libcairo2

1.325 MB 	 e2fsprogs

1.332 MB 	 bash-completion

1.357 MB 	 ntfs-3g

1.360 MB 	 gstreamer1.0-pulseaudio

1.364 MB 	 libp11-kit0

1.385 MB 	 gtk2-engines

1.407 MB 	 openssh-server

1.408 MB 	 openssl

1.411 MB 	 gpg

1.433 MB 	 libcurl4-openssl-dev

1.433 MB 	 mc

1.438 MB 	 libusb-1.0-doc

1.477 MB 	 mousepad

1.499 MB 	 libx11-6

1.502 MB 	 diffutils

1.511 MB 	 libunistring2

1.559 MB 	 xarchiver

1.569 MB 	 sysstat

1.584 MB 	 kbd

1.624 MB 	 libdb5.3

1.635 MB 	 libx11-data

1.668 MB 	 gvfs-backends

1.672 MB 	 rsyslog

1.701 MB 	 libslang2

1.717 MB 	 console-setup-linux

1.723 MB 	 cups-filters

1.738 MB 	 libharfbuzz0b

1.742 MB 	 automake

1.748 MB 	 smbclient

1.760 MB 	 smartmontools

1.771 MB 	 gnupg-utils

1.774 MB 	 libxml2

1.889 MB 	 findutils

1.899 MB 	 ffmpeg

1.942 MB 	 libstdc++6

1.994 MB 	 iptables

2.044 MB 	 fonts-liberation

2.050 MB 	 terminator

2.082 MB 	 x11-apps

2.133 MB 	 alsa-utils

2.153 MB 	 xterm

2.184 MB 	 nano

2.187 MB 	 xfce4-terminal

2.196 MB 	 bison

2.213 MB 	 numix-gtk-theme

2.243 MB 	 libncurses-dev

2.267 MB 	 xscreensaver

2.268 MB 	 libdns-export1104

2.271 MB 	 xserver-xorg-legacy

2.481 MB 	 passwd

2.497 MB 	 iproute2

2.514 MB 	 keyboard-configuration

2.515 MB 	 libgdk-pixbuf2.0-common

2.608 MB 	 login

2.681 MB 	 libgnutls30

2.683 MB 	 packagekit

2.714 MB 	 fonts-stix

2.733 MB 	 libcairo2-dev

2.803 MB 	 vim

2.815 MB 	 tar

2.885 MB 	 fonts-dejavu-core

2.968 MB 	 tzdata

2.993 MB 	 libc-bin

3.025 MB 	 libapt-pkg5.0

3.031 MB 	 fonts-symbola

3.161 MB 	 wpasupplicant

3.173 MB 	 wget

3.271 MB 	 btrfs-progs

3.483 MB 	 dmz-cursor-theme

3.603 MB 	 xfonts-75dpi

3.610 MB 	 xcursor-themes

3.629 MB 	 libssl1.1

3.650 MB 	 sudo

3.723 MB 	 libglib2.0-0

3.852 MB 	 apt

3.975 MB 	 aptitude

4.005 MB 	 xfonts-100dpi

4.010 MB 	 util-linux

4.068 MB 	 ncurses-term

4.130 MB 	 libc-l10n

4.494 MB 	 gnupg-l10n

4.608 MB 	 p7zip-full

4.679 MB 	 bluez

4.714 MB 	 shared-mime-info

4.719 MB 	 librsvg2-2

4.845 MB 	 blueman

5.684 MB 	 libgtk2.0-0

5.908 MB 	 xkb-data

6.089 MB 	 brltty

6.310 MB 	 openprinting-ppds

6.330 MB 	 bash

6.518 MB 	 dpkg

6.998 MB 	 xfonts-base

7.476 MB 	 libssl-dev

7.888 MB 	 libgirepository1.0-dev

8.016 MB 	 udev

8.813 MB 	 linux-dtb-edge-rockchip64

9.518 MB 	 libc6

9.575 MB 	 perl-base

10.445 MB 	 evince-common

10.498 MB 	 fonts-freefont-ttf

11.077 MB 	 python3-numpy

11.486 MB 	 libwebsocketpp-doc

12.696 MB 	 systemd

13.186 MB 	 python3-matplotlib

14.844 MB 	 coreutils

14.894 MB 	 binutils-avr

14.929 MB 	 nlohmann-json3-dev

15.664 MB 	 cmake

15.729 MB 	 locales

16.603 MB 	 numix-icon-theme-circle

16.876 MB 	 fonts-arphic-ukai

19.463 MB 	 libgtk2.0-common

20.518 MB 	 fonts-arphic-uming

24.479 MB 	 libatlas-base-dev

26.176 MB 	 adwaita-icon-theme

28.179 MB 	 fonts-nanum

28.228 MB 	 binutils-arm-none-eabi

30.833 MB 	 libicu63

34.398 MB 	 git

35.333 MB 	 unicode-data

41.216 MB 	 avr-libc

47.330 MB 	 numix-icon-theme

68.302 MB 	 gcc-avr

89.584 MB 	 linux-image-edge-rockchip64

183.311 MB 	 libgl1-mesa-dri

473.239 MB 	 gcc-arm-none-eabi

524.755 MB 	 libnewlib-arm-none-eabi
</details>


Quels paquets ne nécessitent pas de dépendances ?

La commande suivante permet de lister tous les paquets installés n'ayant pas de dépendances; en ajoutant `>/tmp/packages-that-no-packages-depends-on.txt`, on récupère cette liste dans un fichier, ce qui donne :
```
 dpkg-query --show --showformat='${Package}\t${Status}\n' | tac | awk '/installed$/ {print $1}' | xargs apt-cache rdepends --installed | tac | awk '{ if (/^ /) ++deps; else if (!/:$/) { if (!deps) print; deps = 0 } }'
>/tmp/packages-that-no-packages-depends-on.txt'
```

<details>
armbian-bsp-cli-mkspi

armbian-buster-desktop-xfce

armbian-firmware

armbian-zsh

avrdude

chrony

cpufrequtils

dfu-util

dhcpcd5

diffutils

ethtool

evtest

f3

fake-hwclock

fbset

gzip

haveged

hdparm

hostname

htop

i2c-tools

ifenslave

iotop

iozone3

iputils-arping

iputils-ping

libboost-all-dev

libcairo2-dev

libcurl4-openssl-dev

libdbus-1-dev

libgirepository1.0-dev

liblmdb-dev

libncurses-dev

libnl-genl-3-dev

libnss-myhostname

libproc-processtable-perl

libsodium-dev

libv4l-dev

libwebsocketpp-dev

libwebsocketpp-doc

libwrap0-dev

linux-dtb-edge-rockchip64

linux-image-edge-rockchip64

linux-u-boot-mkspi-edge

lshw

makerbase-client

matchbox-keyboard

mmc-utils

nano

netcat-openbsd

netplan.io

nlohmann-json3-dev

perl-openssl-defaults

python3-libgpiod

python3-matplotlib

screen

smartmontools

stm32flash

stress

sysstat

unicode-data

vlan

wireguard-tools

wireless-regdb

xinput
</details>

Quelques paquets candidats à suppression :
- cups (gestion imprimantes «classiques»)
- bluez (bluetooth)
- alsa (son)
- xfce (interface «Desktop»)
- …

  
