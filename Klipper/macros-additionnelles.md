## MACROS ADDITIONNELLES

Quelques unes des macros ajoutées. 

L'utilisateur [@frix-x](https://github.com/Frix-x/klippain) fournit un jeu de macros apportant tout un tas de possibilités. Je détaille celles que j'utilise dans ce [document](./klippain.md).

```
#       KLIPPAIN (Frix-x)       #
#[include macros/misc/console.cfg]
#[include macros/light_sound/*.cfg]
## HELPERS
# Frix-x/klipper-voron-v2
# EtteGit/EnragedRabbitProject
# MapleLeafMakers/KlipperMacros
#[include macros/helpers/*.cfg]
## CALIBRATION
# Frix-x/klipper-voron-v2
#[include macros/calibration/*.cfg]
```

L'utilisateur [@rootiest](https://github.com/rootiest/zippy-klipper_config) fournit un jeu de macros apportant tout un tas de possibilités. Je détaille celles que j'utilise dans ce [document](./zippy.md).
```
#       ZIPPY (rootiest)       #
#[include macros/zippy/bed_leveling.cfg]
#[include macros/zippy/shaping.cfg]
#[include macros/zippy/smart-m600.cfg]
#[include macros/zippy/sensorless_homing_override.cfg]
[include macros/zippy/get_probe_limits.cfg]
[include macros/zippy/test_speed.cfg]
[include macros/zippy/tunes.cfg]
[include macros/zippy/zippystats.cfg]
```

Les macros Qidi Tech et les paramètres système de la platine de tête (déjà inclus dans le printer.cfg sauf la section [mcu MKS_THR] que j'ai ajouté dans mon printer.cfg. La ligne [include …] est donc commentée (doublon)).
```
#        QIDI TECH macros      #
[include macros/qidi_macros.cfg]
#      Hotend Tool Head         #
#[include MKS_THR.cfg]
```

Klipper ne gère d'origne pas tous les Gcodes Marlin => création de macros pour les ajouter.
```
#        MARLIN G-CODE         #
#[include macros/heater_override.cfg]
#[include macros/marlin_macros.cfg]
```

Mises à l'origine uniquement si les axes n'y sont pas déjà
```
#            HOMING            #
[include macros/homing_alternate.cfg]
```

Utilisant pour la domotique HomeAssistant, mes prises électriques avec firmware Tasmota peuvent être gérées via Moonraker et quelques macros [voir ce document](../Upgrades/ha.md).
```
#       SHUTDOWN / REBOOT      #
[include macros/HA_power_macros.cfg]
```

Gestion du chargement / déchargement / purge du filament [filament](filament.md) 
```
#           FILAMENT            #
#[include macros/filament.cfg]
```

Utilisation de scripts shell [GSC](../Upgrades/gcode_shell_command.md)
```
#         SHELL_COMMAND         #
[include macros/shell_command.cfg]
```

Gestion des [PIDs](./pids.md)
```
#        PID HOTEND / BED       #
[include macros/pid.cfg]
```

[Sauvegarde](variables.md) de paramètres dans des variables afin de pouvoir les réutiliser ultérieurement
```
#           Variables           #
[include macros/save_variables.cfg]
```

Le client «universel» Fluidd / Mainsail [ici](./fluidd-mainsail-client.md)
```
#    Client Fluidd / Mainsail   #
[include client.cfg]
```

Complément après installation d'une caméra pour faire des vidéos «[timelapse](../Upgrades/timelapse.md)»
```
#      TIMELAPSE PLUGIN         #
[include timelapse.cfg]
```

Ne palper le plateau qu'en fonction de la pièce imprimée [KAMP](./kamp.md)
```
# Klipper Adaptative Mesh Purge #
[include Adaptive_Mesh.cfg]
```

Pour en apprendre plus sur les macros, je recommande chaudement la lecture de [ce guide](https://github.com/rootiest/zippy_guides/blob/main/guides/macros.md)
