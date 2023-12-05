## Comment formater une carte SD > 32 Go en FAT32 avec Windows 10

<p>
Pour des cartes microSD de plus de 32 Go, Windows 10 n'offre que la possibilité de formater en NTFS ou exFAT.
Vous pouvez créer une petite partition (par exemple 4 Go) sur une carte microSD de grande taille (par exemple 64 Go)
pour bénéficier de l'option de formatage FAT32.

* insérer la carte microSD dans le lecteur de carte PC
* ouvrir le Gestionnaire de disques( <kbd>Win</kbd>+<kbd>x</kbd>, <kbd>k</kbd> )
  * Gestion des disques : supprimer toutes les partitions de la carte microSD
    * cliquer avec le bouton droit de la souris sur chaque partition > "Supprimer volume..."
    * répéter l'opération jusqu'à ce qu'il n'y ait plus de partitions sur la carte
  * Gestion des disques : créer une nouvelle partition FAT32
    * cliquer avec le bouton droit de la souris sur "Non alloué" > "Nouveau volume simple..."
    * Bienvenue dans l'assistant Nouveau volume simple : cliquez sur "Suivant"
    * Indiquer la taille du volume: 4096 > "Suivant"
    * Attribuer une lettre de lecteur ou un chemin d'accès : (au choix) > "Suivant"
    * Formater la partition : Formatez ce volume avec les paramètres suivants :
      * Système de fichiers: FAT32
      * Taille de l'unité d'allocation: Défaut ou 4096 octets (4ko)
      * Étiquette du volume: au choix
      * Effectuer un formatage rapide: &#9745;

Vous devriez maintenant avoir une partition FAT32 sur votre carte microSD. Elle pourra être utilisée pour effectuer le flashage de firmwares.

Autre possibilité :

* ouvrir cmd avec les droits d'administrateur
* Exécutez diskpart
* tapez "list disk"
* trouvez votre carte sd (par exemple Disque 5)
* tapez "select disk 5"
* S'il n'y a qu'une seule partition, tapez "select partition 1". S'il y en a plusieurs, supprimez toutes les partitions et créez-en une.
* tapez "format FS=FAT32 QUICK"
* c'est fait. Une partition de 32 Go en FAT32.

</p>
