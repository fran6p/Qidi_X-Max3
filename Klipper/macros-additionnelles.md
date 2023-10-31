## MACROS ADDITIONNELLES

Quelques unes des macros ajoutées. 

J'ai récupéré les macros d'aide à la calibration de l'utilisateur [@frix-x](https://github.com/Frix-x/klippain). Je détaille celles que j'utilise dans ce [document](./klippain.md).

1. KLIPPAIN

```
#       KLIPPAIN (Frix-x)       #
## CALIBRATION
# Frix-x/klipper-voron-v2
[include macros/klippain/*.cfg]
```

Idem pour l'utilisateur [@rootiest](https://github.com/rootiest/zippy-klipper_config) qui fournit quelques macros intéressantes. Je détaille celles que j'utilise dans ce [document](./zippy.md).

2. ZIPPY

```
#       ZIPPY (rootiest)       #
[include macros/zippy/bed_leveling.cfg]
[include macros/zippy/shaping.cfg]
[include macros/zippy/smart-m600.cfg]
[include macros/zippy/sensorless_homing_override.cfg]
[include macros/zippy/get_probe_limits.cfg]
[include macros/zippy/test_speed.cfg]
[include macros/zippy/tunes.cfg]
[include macros/zippy/zippystats.cfg]
```

Les macros Qidi Tech et les paramètres système de la platine de tête (tool board) qui sont repris dans le printer.cfg sauf la section [mcu MKS_THR]. Plutôt que d'inclure ce fichier, j'ai ajouté cette section **[mcu MKS_THR]** dans mon printer.cfg et commenté la ligne [include MKS_THR.cfg] (doublon)).

3. QIDI

```
#        QIDI TECH macros      #
[include macros/qidi_macros.cfg]
#      Hotend Tool Head         #
#[include MKS_THR.cfg]
```

Klipper n'utilise pas d'origine la totalité des [Gcodes](https://www.klipper3d.org/fr/G-Codes.html#g-codes) Marlin mais fait un usage intensif de Gcodes étendus => création de macros pour en reproduire quelques uns [marlin](./marlin.md).

4. MARLIN

```
#        MARLIN G-CODE         #
#[include macros/heater_override.cfg]
[include macros/marlin_macros.cfg]
```

Le point 5, pour le moment ne fonctionne pas comme il se doit avec la X-Max 3. Je continue de chercher pourquoi alors qu'avec mes autres imprimantes «klipperisées» ça fonctionne.
<details>
  
5. [Mises à l'origine conditionnelle](./homing-alt.md)

```
#            HOMING            #
[include macros/homing_alternate.cfg]
```

</details>

Utilisant pour ma domotique, HomeAssistant, mes prises électriques avec firmware Tasmota peuvent être gérées via Moonraker et quelques macros [voir ce document](../Upgrades/ha.md).

6. Moonraker, gestion de l'alimentation électrique

```
#       SHUTDOWN / REBOOT      #
[include macros/HA_power_macros.cfg]
```

7. Gestion du chargement / déchargement / purge du filament [filament](filament.md) 

```
#           FILAMENT            #
[include macros/filament.cfg]
```

8. Utilisation de scripts shell [GSC](../Upgrades/gcode_shell_command.md)

```
#         SHELL_COMMAND         #
[include macros/shell_command.cfg]
```

9. Gestion des [PIDs](./pids.md)

```
#        PID HOTEND / BED       #
[include macros/pid.cfg]
```

10. [Sauvegarde](variables.md) de paramètres dans des variables afin de pouvoir les réutiliser ultérieurement

```
#           Variables           #
[include macros/save_variables.cfg]
```

11. Le client «universel» Fluidd / Mainsail [voir ici](./fluidd-mainsail-client.md)

```
#    Client Fluidd / Mainsail   #
[include client.cfg]
```

12. Complément après installation d'une caméra pour réaliser des vidéos «[timelapse](../Upgrades/timelapse.md)»

```
#      TIMELAPSE PLUGIN         #
[include timelapse.cfg]
```

13. Ne palper le plateau qu'en fonction de la pièce imprimée [KAMP](./kamp.md)

```
# Klipper Adaptative Mesh Purge #
[include Adaptive_Mesh.cfg]
```

> Pour en apprendre plus sur les macros, je recommande chaudement la lecture de [ce guide](https://github.com/rootiest/zippy_guides/blob/main/guides/macros.md)
