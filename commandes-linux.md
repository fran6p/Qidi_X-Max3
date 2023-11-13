# Référence de quelques commandes

Compilation de quelques commandes Unix/Linux utiles. Klipper nécessite une connaissance de la ligne de commande pour son utilisation avec un terminal SSH.

-----------------------------

## Linux

- Se placer dans son répertoire personnel (connecté en utilisateur `mks`)
```
cd
   ou
cd ~  
```

- Lancer KIAUH
```
./kiauh/kiauh.sh
```
  
- Régler la zone horaire
```
sudo timedatectl set-timezone Europe/Paris
```

- Modifier son mot de passe
```
passwd
```

- Trouver le port série du MCU pour le fichier `printer.cfg`
```
ls /dev/serial/by-id/*
```

- Afficher le contenu du fichier journal (journal de toutes les activités)
```
journalctl 
```

- Vider le fichier journal
```
sudo journalctl --vacuum-time=1seconds
```

- Gestions des paquets (packages)
  - mettre à jour le système
  ```
  sudo apt update 
  sudo apt upgrade
  ```
  ou en une seule ligne
  ```
  sudo apt update && sudo apt upgrade
  ```
  - faire un peu de ménage
  ```
  sudo apt clean
  sudo apt autoremove
  ```
  - installer un paquet
  ```
  sudo apt install NOM-DU-PAQUET
  ```
- Divers
  - réseau
    - afficher les réseaux Wifi à proximité
    ```
    sudo iwlist wlan0 scan | egrep "Cell|ESSID|Signal|Rates"
    ```
    - Afficher les adresses IP des cartes réseaux
    ```
    ip address
    ```
  - USB
    - Quel matériel est connecté sur les ports USB (ajouter -v ou -vv pour informations détaillées)
    ```
    lsusb
    ```
  - OS, Processeur, Partitions
  ```
  lscpu
  lshw
  lsblk
  ```
  - quelle version du SI (OS) est installée
  ```
  cat /etc/os-release
  cat /etc/armbian-release
  cat /etc/armbian-image-release
  cat /etc/*release
  ```

- Redémarrer le système (reboot)
```
sudo reboot
```

- Arrêter le système (shutdown)
```
shutdown -h now
```

- Afficher les tâches / processus en cours
```
htop
```

- Afficher le nom du système (adresses IP => -I)
```
hostname
hostname -I
```

- Télécharger un fichier (remplacer URL avec l'adresse Web)
```
wget URL
```

### Pour aller plus loin

- [aide-mémoire des commandes essentielles](https://www.linuxtricks.fr/wiki/memo-commandes-de-base-linux)
- [un autre](https://www.ionos.fr/digitalguide/serveur/configuration/commandes-linux/)
- [une formation Linux](https://blog.microlinux.fr/formation-linux/)

------------------------------

## Klipper

- Calibration Pid
```
PID_CALIBRATE HEATER=extruder TARGET=215
PID_CALIBRATE HEATER=heater_bed TARGET=50
```

- Calibration de l'avance à la pression (pressure advance)
  - lancer cette commande
  ```
  SET_VELOCITY_LIMIT SQUARE_CORNER_VELOCITY=1 ACCEL=500
  ```
  - puis celle-ci (en fonction du type d'extrudeur)
    - Direct Drive
    ```
    TUNING_TOWER COMMAND=SET_PRESSURE_ADVANCE PARAMETER=ADVANCE START=0 FACTOR=.005
    ```  
    - Bowden
    ```
    TUNING_TOWER COMMAND=SET_PRESSURE_ADVANCE PARAMETER=ADVANCE START=0 FACTOR=.020
    ```
  - la valeur du paramètre `pressure_advance` se calcule de la manière suivante `pressure_advance = <début> + <hauteur_mesurée> * <facteur>` (Exemple: 0 + 12,90 * 0,020 = 0,258 ) 

### Pour aller plus loin

- [Klipper Gcodes](https://www.klipper3d.org/fr/G-Codes.html#g-codes)
- [Klipper Avance à la pression](https://www.klipper3d.org/fr/Pressure_Advance.html#avance-a-la-pression)
- [Guide de calibration d'Ellis](https://ellis3dp.com/Print-Tuning-Guide/)
