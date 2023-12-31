## Notes flashage Klipper

---
Si l'on mettait à jour Klipper (v0.11+), il faudrait reflasher les différents «mcu» utilisés par l'imprimante.

Sinon après démarrage, Klipper le signalerait et tant que cela n'aurait pas été fait, l'imprimante ne serait plus fonctionnelle.

    Message d'erreur : « version mismatch : one of your mcu versions is outdated »
    (incompatibilité de version : une des versions des mcu est obsolète)

Il faudrait compiler trois firmwares (on peut utiliser KIAUH installé sur le système ou aller consulter la [documentation](https://www.klipper3d.org/fr/Installation.html#compilation-et-flashage-du-micro-controleur) ) :

1. un pour le MCU (STM32F402),
2. un pour la carte de la tête d'impression (RP2040) et
3. un pour le Rockchip RK3328 (équivalent du MCU secondaire RPi) 

Et ensuite les flasher chacun en utilisant un processus différent :

- le MCU (1) nécessite l'utilisation de la carte SD sur la carte contrôleur [voir ici](https://github.com/makerbase-mks/Klipper-for-MKS-Boards/tree/main/MKS%20SKIPR%20V1.x), mais îl doit être possible de mettre à jour après le `make menuconfig && make` via l'utilisation du script `./scripts/flash-sdcard.sh` puisque le firmware est déjà installé [voir ici](https://www.klipper3d.org/fr/SDCard_Updates.html#mises-a-jour-via-la-carte-sd)
- la mise à jour du «Pi» (3) est la plus facile et peut être faite sous Linux [voir ici](https://www.klipper3d.org/fr/RPi_microcontroller.html#microcontroleur-rpi)..
- mettre à jour la tête d'impression (2) [voir ici](https://github.com/makerbase-mks/MKS-THR36-THR42-UTC#thr3642-firmware-update)
    - presser physiquement sur le bouton de démarrage (boot) de la tête d'impression au démarrage de l'imprimante
    pour faire apparaître un lecteur spécial dans Linux (via le MCU) sur lequel on copie le micrologiciel (.uf2),
    le flashage se réalise seul une fois le fichier copié.
