## fluidd-config (mainsail-config)

Fluidd et Mainsail fournissent un fichier client regroupant des macros G-code étendu indispensables au bon fonctionnement de Klipper.

Ces trois macros sont également présentes dans le fichier `printer.cfg` de la X-Max 3 sous une forme différente :

- CANCEL_PRINT
- PAUSE
- RESUME

Quelques macros facilitant la mise en pause de l'impression et l'obtention de statistiques :

- SET_PAUSE_NEXT_LAYER
- SET_PAUSE_AT_LAYER
- SET_PRINT_STATS_INFO
 
Une section `[gcode_macro _CLIENT_VARIABLE]` à recopier au début du `printer.cfg` et à modifier (ou pas) pour tenir compte des caractéristiques de son matériel.

Et quelques directives, elles aussi indispensables :

- [virtual_sdcard]
- [pause_resume]
- [display_status]
- [respond]

Les macros dont le nom débute par le caractère souligné « _ » sont des aides pour les autres macros et ne devraient pas être modifiées.

> La présence de ce caractére en début du nom de la macro permet de ne pas les afficher dans la liste des macros des interfaces Web, c'est un peu ***l'équivalent du point « . » au début d'un nom de fichier pour le cacher sous Linux***.

### Installation

Connexion en ssh sur la carte, utilisateur « mks » et son mot de passe, cloner le dépôt, créer le lien symbolique pour en profiter :

```bash
cd ~
git clone https://github.com/fluidd-core/fluidd-config.git
ln -sf ~/fluidd-config/client.cfg ~/klipper_config/client.cfg
```

Ce fichier sera ensuite inclus via un `[include client.cfg]` dans le printer.cfg pour qu'il soit pris en compte.

**NB:** le `printer.cfg` de Qidi Tech possédant lui aussi des macros PAUSE, RESUME, CANCEL_PRINT, il faudra :
- soit supprimer celles-ci du fichier,
- soit placer la directive `include` après ces macros G-Code,
- soit encore scinder le `printer.cfg` en deux (voir [Ma configuration](./configuration.md))

Plus d'informations [Fluidd-config](https://github.com/fluidd-core/fluidd-config) ou [Mainsail-config](https://github.com/mainsail-crew/mainsail-config)
