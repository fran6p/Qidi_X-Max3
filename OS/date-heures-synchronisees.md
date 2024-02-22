# Gestion date et heure

La carte contrôleur ne possède pas de pile permettant de maintenir date et heure correctes. L'horodatage de certains fichiers permet aisément de s'en rendre compte.

L'absence de pile RTC peut normalement être compensée en récupérant date et heure via connexions sur des serveurs de temps [(NTP)](https://fr.wikipedia.org/wiki/Network_Time_Protocol).

Mais, au moins sur mon système la consultation de ces serveurs de temps ne se fait pas.

Deux sytèmes sont activés et entrent en conflits pour synchroniser heure  / date :

- chronyd
- systemd-timesyncd

Ayant plus d'affinités avec chrony, on va désactiver le daemon `systemd-timesync`

```javascript
systemctl status systemd-timesyncd
systemctl stop systemd-timesyncd
systemctl disable --now systemd-timesyncd.service
systemctl status systemd-timesyncd
```

Activer après configuration de son fichier de configuration, le daemon `chrony`
```javascript
cat /etc/chrony/chrony.conf
sudo nano /etc/chrony/chrony.conf
sudo systemctl restart chronyd
systemctl status chronyd
chronyc sources
date
chronyc tracking
```

La date et l'heure sont désormais correctes et mises à jour régulièrement.

# ALTERNATIVE

Retirer les droits d'exécution du binaire `chronyd`, recharger la configuration, redémarrer le daemon `systemd-timesyncd`

```
sudo chmod -x /usr/sbin/chronyd
sudo systemctl daemon-reload
sudo systemctl restart systemd-timesyncd
systemctl status systemd-timesyncd
systemctl status chronyd
date
```

La date est désormais à jour, synchronisée sur les serveurs de temps.

# ALTERNATIVE2

## PRÉALABLE

Les paquets **ntp** et **chrony** si installés doivent être désinstallés, inutiles, ils empêchent la synchronisation horaire. Le système perd l'heure et l'utilisation de git, apt provoquent des erreurs à cause de l'heure système non à jour :

```
sudo apt remove ntp chrony
```

Utiliser la commande `timedatectl` de **systemd**
- paramétrer la zone horaire :
```
timedatectl set-timezone Europe/Paris
```
- lister les zones horaires :
```
timedatectl list-timezones
```
- activer la synchronisation horaire via serveurs de temps (ntp) :
```
timedatectl set-ntp 1
```
- régler la date  et l'heure (inutile si un accès réseau est disponible utilisant la synchro ntp) :
```
timedatectl set-time '2024-02-20 18:15:22'
```

Le démarrage manuel de `systemd-timesyncd` n'est pas nécessaire, `timedatectl` s'en charge 

Pour vérifier que tout est correct, un simple `timedatectl` affichera les infos :
```bash
mks@mkspi:~$ timedatectl
               Local time: Thu 2024-02-22 18:09:36 CET
           Universal time: Thu 2024-02-22 17:09:36 UTC
                 RTC time: Thu 2024-02-22 17:09:14
                Time zone: Europe/Paris (CET, +0100)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
```

:smiley:
