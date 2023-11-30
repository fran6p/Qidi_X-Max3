## Préserver l'historique des impressions

A chaque mise à jour si aucune précaution n'a été prise, l'historique des impressions est remis à zéro ☹️

Il est possible de faire une sauvegarde de la base de données pour pouvoir ensuite la réinjecter.

### Comment faire ?

1. Connecté en ssh sur la carte en utilisateur **mks**, installer le paquet `lmdb-utils`
   
```
sudo apt install lmdb-utils
```

2. Faire une sauvegarde de la base actuelle dans un fichier texte 

```
cd ~
mdb_dump -f bkup-moonraker-db.txt -a .moonraker_database
```

3. Faire la mise à jour Qidi (clé USB contenant à la racine le dossier QD_Update et son contenu)

4. Toujours connecté en ssh, utilisateur **mks**
  - Arrêter le daemon **moonraker**
  ```
  sudo systemctl stop moonraker
  ```
  - Supprimer les deux fichiers du répertoire **.moonraker_database** (répertoire caché)
  ```
  cd .moonraker_database
  rm -rf data.mdb
  rm -rf lock.mdb
  ```
  - Remonter à la racine du répertoire personnel (**/home/mks**), injecter la sauvegarde de la base, démarrer **moonraker**
  ```
  cd ~
  mdb_load -f bkup-moonraker-db.txt -s -T ~/.moonraker_database
  sudo systemctl start moonraker       
  ```   

Source: [Voron Community Documentation](https://docs.vorondesign.com/community/howto/kyleisah/transferring_machine_history.html#something-went-wrong-moonraker-isnt-coming-back-up)

Il doit être possible de créer une macro «shell_command» pour automatiser la sauvegarde la base (point 2 ci-dessus). A suivre donc…
