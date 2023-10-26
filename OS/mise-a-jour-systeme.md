## Mise à jour du système

Aucune notification de la part du système ne nous signale quand / s’il y a une mise à jour disponible.
C’est à l’utilisateur d’aller consulter soit le [Github de la X-Max 3](https://github.com/QIDITECH/QIDI_MAX3/releases), soit [cette page](https://qidi3d.com/pages/software-firmware?z_code=p12711140855145122921) du site QidiTech.

Quelques constats :

- pour des mises à jour, j’ai déjà connu mieux et surtout plus rapide (entre 30 et 40 minutes, en cause la mise à jour de l’écran en mode série (débit lent))
   - => un point que Qiditech devrait améliorer, à mon avis
- cette mise à jour remplace purement et simplement le fichier «printer.cfg» et remets le «moonraker.conf» ainsi que le «config.mksini» originels 
   - => si des modifications y avaient été apportées, elles seront perdues (penser à faire une sauvegarde régulière)
- après cette mise à jour du système, il faut penser à refaire deux étapes d’étalonnage
   - => à cause du point précédent , les paramètres des résultats des calibrations en fin du fichier sont effacés (la section «SAVE_CONFIG DO NOT EDIT» est vide) :
        - topographie du plateau («bed mesh») incluant le réglage du Zoffset qui sera enregistré dans le fichier «config.mksini»,
        - compensation de résonances (Input shaping)
- les paramètres de connexion de l'accès Wifi sont perdus, il faut le reparamétrer (ou utiliser  une connexion Ethernet)
- l’historique des impressions est remis à zéro
   - => ce point là est vraiment «pénible» (faire une sauvegarde du dossier caché `.moonraker_database` du répertoire utilisateur `/home/mks` et le recopier après la mise à jour pour remplacer la base remise à zéro).

### Comment je procède avant de mettre à jour le système

Avant toute mise à jour, je sauvegarde via WinSCP:
- le dossier `~/klipper_config`
- le dossier caché `~/.moonraker_database`

Je procède ensuite à la mise à jour du système (mi-octobre 2023, V4.3.10) via la clé USB dans laquelle le dossier QD_Update et son contenu ont été copié à la racine de la clé «sans nom» :smirk: .

Via ssh, en tant qu'utilisateur `mks`, j'arrête les services `moonraker` et `klipper` et fais une copie du nouveau `printer.cfg`

```bash
sudo systemctl stop moonraker
sudo systemctl stop klipper
cp ~/klipper_config/printer.cfg ~/klipper_config/printer-qidi-v4310.cfg
```

Via WinSCP, je recopie le dossier  `~/.moonraker_database` dans le home de mks, idem pour le dossier `klipper_config`

Via ssh, je relance les services 

```bash
sudo systemctl start moonraker
sudo systemctl start klipper
```

Je cherche les modifications apportées au fichier printer.cfg (diff, Winmerge) et les reporte manuellement dans mon printer.cfg sauvegardé si nécessaire.

### Examen rapide des fichiers constituants une mise à jour

L'archive QD_Update.zip (version 4.3.8) contient trois fichiers :
1. `printer.cfg`, le fichier de configuration de l'imprimante regroupant à la fois les paramètres matériels et les macros Qidi
2. `QD_Max_SOC` (lui même une archive que 7Zip (et autres logiciels de même fonctionnalité) peut ouvrir)
3. `QD_Max3_UI5.0` est le firmware de l'écran tactile, c'est lui qui prend autant de temps à être flashé en mode série

Comme vu plus haut, lors du flashage, le `printer.cfg` est  purement et simplement remplacé par celui de l'archive… ***Rien n'empêche avant la recopie du dossier QD_Update de remplacer le `printer.cfg` par le vôtre*** :smirk:

#### QD_Max_SOC

7zip peut décompresser ce «fichier»: il contient une autre archive `data.tar` qui une fois décompressée donne cette arborescence :

![qd_max_soc](../Images/qd_update-qd_max_soc-path.jpg)



:smile:
