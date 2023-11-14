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
- lancer l'installation
  ```
  sudo make install
  ```
- démarrer le service `crowsnest`
  ```
  sudo systemctl restart crowsnest
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

