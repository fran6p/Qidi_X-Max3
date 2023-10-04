# Gestion date et heure

La carte contrôleur ne possède pas de pile permettant de maintenir date et heure correctes. L'horodatage de certains fichiers permet aisé/ent de s'en rendre compte.

L'absence de pile RTC peut normalement être compensée en récupérant date et heure via connexions sur des serveurs de temps [(NTP)](https://fr.wikipedia.org/wiki/Network_Time_Protocol).

Mais, au moins sur mon système la consultation de ces serveurs de temps ne se fait pas.

Deux sytèmes sont activés et entrent en conflis pour synchroniser heure  / date :

- chronyd
- systemd-timesyncd

Ayant plus d'affinités avec chrony, on va désactiver le daemon ̀`systemd-timesync`

```
systemctl status systemd-timesyncd
systemctl stop systemd-timesyncd
systemctl disable --now systemd-timesyncd.service
systemctl status systemd-timesyncd
```

Activer après configuration de son fichier de configuration, le daemon `chrony`
```
cat /etc/chrony/chrony.conf
sudo nano /etc/chrony/chrony.conf
sudo systemctl restart chronyd
systemctl status chronyd
chronyc sources
date
chronyc tracking
```

La date et l'heure sont désormais correctes et mises à jour régulièrement.
