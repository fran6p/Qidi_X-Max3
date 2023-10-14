## Mise à jour du système

Aucune notification de la part du système ne nous signale quand / s’il y a une mise à jour disponible.
C’est à l’utilisateur d’aller consulter soit le Github de la X-Max, soit cette page du site QidiTech.

Quelques constats :

- pour des mises à jour, j’ai déjà connu mieux et surtout plus rapide (entre 30 et 40 minutes, en cause la mise à jour de l’écran en mode série (débit lent))
    => un point que Qiditech devrait améliorer, à mon avis
- cette mise à jour remplace purement et simplement le fichier «printer.cfg»
    => si des modifications y avaient été apportées, elles seront perdues (penser à faire une sauvegarde régulière)
- après cette mise à jour du système, il faut penser à refaire deux étapes d’étalonnage
    => à cause du point précédent , les paramètres des résultats des calibrations en fin du fichier sont effacés (la section «SAVE_CONFIG DO NOT EDIT» est vide) :
        - topographie du plateau («bed mesh») incluant le réglage du Zoffset,
        - compensation de résonances (Input shaping)
- l’historique des impressions est remis à zéro
    => ce point là est vraiment «pénible» (faire une sauvegarde du dossier caché .moonraker_database du répertoire utilisateur /home/mks et le recopier après la mise à jour pour remplacer la base remise à zéro).

### Comment je procède avant de mettre à jour le système

Avant toute mise à jour, je sauvegarde via WinSCP:
- le dossier `~/klipper_config`
- le dossier caché `~/.moonraker_database`

Je procède ensuite à la mise à jour du système (mi-octobre 2023, V4.3.10).

Via ssh, en tant qu'utilisateur `mks`, j'arrête les services `moonraker` et `klipper` et fais une copie du nouveau `printer.cfg`

    `sudo systemctl stop moonraker`
    `sudo systemctl stop klipper`
    `cp ~/klipper_config/printer.cfg ~/klipper_config/printer-qidi-v4310.cfg`

Via WinSCP, je recopie le dossier  `~/.moonraker_database` dans le home de mks, idem pour le dossier `klipper_config`

Je cherches les modifications apportées au fichier printer.cfg (diff, Winmerge) et les reporte manuellement dans mon printer.cfg sauvegardé.

