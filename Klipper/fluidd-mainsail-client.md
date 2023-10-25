## fluidd-config (mainsail-config)

Fluidd et Mainsail fournissent un fichier client regroupant des macros G-code étendu indispensables au bon fonctionnement de Klipper.

Ces trois macros sont également présentes dans le fichier `printer.cfg` de la X-Max 3 sous une forme différente :

- CANCEL_PRINT
- PAUSE
- RESUME

<details>

```
[gcode_macro CANCEL_PRINT]
description: Cancel the actual running print
rename_existing: CANCEL_PRINT_BASE
gcode:
  ##### get user parameters or use default #####
  {% set client = printer['gcode_macro _CLIENT_VARIABLE'] | default({}) %}
  {% set allow_park = client.park_at_cancel | default(false) | lower == 'true' %}
  {% set retract = client.cancel_retract | default(5.0) | abs %}
  ##### define park position #####
  {% set park_x = "" if (client.park_at_cancel_x | default(none) is none)
            else "X=" ~ client.park_at_cancel_x %}
  {% set park_y = "" if (client.park_at_cancel_y | default(none) is none)
            else "Y=" ~ client.park_at_cancel_y %}
  {% set custom_park = park_x | length > 0 or park_y | length > 0 %}
  ##### end of definitions #####
  # restore idle_timeout time if needed
  {% if printer['gcode_macro PAUSE'].restore_idle_timeout > 0 %}
    SET_IDLE_TIMEOUT TIMEOUT={printer['gcode_macro PAUSE'].restore_idle_timeout}
  {% endif %}
  {% if (custom_park or not printer.pause_resume.is_paused) and allow_park %} _TOOLHEAD_PARK_PAUSE_CANCEL {park_x} {park_y} {% endif %}
  _CLIENT_RETRACT LENGTH={retract}
  TURN_OFF_HEATERS
  M106 S0
  # clear pause_next_layer and pause_at_layer as preparation for next print
  SET_PAUSE_NEXT_LAYER ENABLE=0
  SET_PAUSE_AT_LAYER ENABLE=0 LAYER=0
  CANCEL_PRINT_BASE

[gcode_macro PAUSE]
description: Pause the actual running print
rename_existing: PAUSE_BASE
variable_restore_idle_timeout: 0
gcode:
  ##### get user parameters or use default #####
  {% set client = printer['gcode_macro _CLIENT_VARIABLE'] | default({}) %}
  {% set idle_timeout = client.idle_timeout | default(0) %}
  {% set temp = printer[printer.toolhead.extruder].target if printer.toolhead.extruder != '' else 0 %}
  {% set restore = printer.toolhead.extruder != '' and params.RESTORE | default(1) | int == 1 %}
  ##### end of definitions #####
  SET_GCODE_VARIABLE MACRO=RESUME VARIABLE=last_extruder_temp VALUE="{{'restore': restore, 'temp': temp}}"
  # set a new idle_timeout value
  {% if idle_timeout > 0 %}
    SET_GCODE_VARIABLE MACRO=PAUSE VARIABLE=restore_idle_timeout VALUE={printer.configfile.settings.idle_timeout.timeout}
    SET_IDLE_TIMEOUT TIMEOUT={idle_timeout}
  {% endif %}
  PAUSE_BASE
  _TOOLHEAD_PARK_PAUSE_CANCEL {rawparams}

[gcode_macro RESUME]
description: Resume the actual running print
rename_existing: RESUME_BASE
variable_last_extruder_temp: {'restore': False, 'temp': 0}
gcode:
  ##### get user parameters or use default #####
  {% set client = printer['gcode_macro _CLIENT_VARIABLE'] | default({}) %}
  {% set velocity = printer.configfile.settings.pause_resume.recover_velocity %}
  {% set sp_move = client.speed_move | default(velocity) %}
  ##### end of definitions #####
  # restore idle_timeout time if needed
  {% if printer['gcode_macro PAUSE'].restore_idle_timeout > 0 %}
    SET_IDLE_TIMEOUT TIMEOUT={printer['gcode_macro PAUSE'].restore_idle_timeout}
  {% endif %}
  {% if printer.idle_timeout.state | upper == "IDLE" and last_extruder_temp.restore %}
    M109 S{last_extruder_temp.temp}
  {% endif %}
  _CLIENT_EXTRUDE
  RESUME_BASE VELOCITY={params.VELOCITY | default(sp_move)}
```

</details>
Quelques macros facilitant la mise en pause de l'impression et l'obtention de statistiques :

- SET_PAUSE_NEXT_LAYER
- SET_PAUSE_AT_LAYER
- SET_PRINT_STATS_INFO

<details>

```
# Usage: SET_PAUSE_NEXT_LAYER [ENABLE=[0 | 1]] [MACRO=<name>]
[gcode_macro SET_PAUSE_NEXT_LAYER]
description: Enable a pause if the next layer is reached
gcode:
  {% set pause_next_layer = printer['gcode_macro SET_PRINT_STATS_INFO'].pause_next_layer %}
  {% set ENABLE = params.ENABLE | default(1) | int != 0 %}
  {% set MACRO = params.MACRO | default(pause_next_layer.call, True) %}
  SET_GCODE_VARIABLE MACRO=SET_PRINT_STATS_INFO VARIABLE=pause_next_layer VALUE="{{ 'enable': ENABLE, 'call': MACRO }}"

# Usage: SET_PAUSE_AT_LAYER [ENABLE=[0 | 1]] [LAYER=<number>] [MACRO=<name>]
[gcode_macro SET_PAUSE_AT_LAYER]
description: Enable/disable a pause if a given layer number is reached
gcode:
  {% set pause_at_layer = printer['gcode_macro SET_PRINT_STATS_INFO'].pause_at_layer %}
  {% set ENABLE = params.ENABLE | int != 0 if params.ENABLE is defined
             else params.LAYER is defined %}
  {% set LAYER = params.LAYER | default(pause_at_layer.layer) | int %}
  {% set MACRO = params.MACRO | default(pause_at_layer.call, True) %}
  SET_GCODE_VARIABLE MACRO=SET_PRINT_STATS_INFO VARIABLE=pause_at_layer VALUE="{{ 'enable': ENABLE, 'layer': LAYER, 'call': MACRO }}"

# Usage: SET_PRINT_STATS_INFO [TOTAL_LAYER=<total_layer_count>] [CURRENT_LAYER= <current_layer>]
[gcode_macro SET_PRINT_STATS_INFO]
rename_existing: SET_PRINT_STATS_INFO_BASE
description: Overwrite, to get pause_next_layer and pause_at_layer feature
variable_pause_next_layer: { 'enable': False, 'call': "PAUSE" }
variable_pause_at_layer  : { 'enable': False, 'layer': 0, 'call': "PAUSE" }
gcode:
  {% if pause_next_layer.enable %}
    RESPOND TYPE=echo MSG='{"%s, forced by pause_next_layer" % pause_next_layer.call}'
    {pause_next_layer.call} ; execute the given gcode to pause, should be either M600 or PAUSE
    SET_PAUSE_NEXT_LAYER ENABLE=0
  {% elif pause_at_layer.enable and params.CURRENT_LAYER is defined and params.CURRENT_LAYER | int == pause_at_layer.layer %}
    RESPOND TYPE=echo MSG='{"%s, forced by pause_at_layer [%d]" % (pause_at_layer.call, pause_at_layer.layer)}'
    {pause_at_layer.call} ; execute the given gcode to pause, should be either M600 or PAUSE
    SET_PAUSE_AT_LAYER ENABLE=0
  {% endif %}
  SET_PRINT_STATS_INFO_BASE {rawparams}

```
 
</details> 

Une section `[gcode_macro _CLIENT_VARIABLE]` à recopier au début du `printer.cfg` et à modifier (ou pas) pour tenir compte des caractéristiques de son matériel.

<details>

```
## Client variable macro for your printer.cfg
#[gcode_macro _CLIENT_VARIABLE]
#variable_use_custom_pos   : False ; use custom park coordinates for x,y [True/False]
#variable_custom_park_x    : 0.0   ; custom x position; value must be within your defined min and max of X
#variable_custom_park_y    : 0.0   ; custom y position; value must be within your defined min and max of Y
#variable_custom_park_dz   : 2.0   ; custom dz value; the value in mm to lift the nozzle when move to park position
#variable_retract          : 1.0   ; the value to retract while PAUSE
#variable_cancel_retract   : 5.0   ; the value to retract while CANCEL_PRINT
#variable_speed_retract    : 35.0  ; retract speed in mm/s
#variable_unretract        : 1.0   ; the value to unretract while RESUME
#variable_speed_unretract  : 35.0  ; unretract speed in mm/s
#variable_speed_hop        : 15.0  ; z move speed in mm/s
#variable_speed_move       : 100.0 ; move speed in mm/s
#variable_park_at_cancel   : False ; allow to move the toolhead to park while execute CANCEL_PRINT [True/False]
#variable_park_at_cancel_x : None  ; different park position during CANCEL_PRINT [None/Position as Float]; park_at_cancel must be True
#variable_park_at_cancel_y : None  ; different park position during CANCEL_PRINT [None/Position as Float]; park_at_cancel must be True
## !!! Caution [firmware_retraction] must be defined in the printer.cfg if you set use_fw_retract: True !!!
#variable_use_fw_retract   : False ; use fw_retraction instead of the manual version [True/False]
#variable_idle_timeout     : 0     ; time in sec until idle_timeout kicks in. Value 0 means that no value will be set or restored
#gcode:

```

</details>

Et quelques directives, elles aussi indispensables :

- [virtual_sdcard]
- [pause_resume]
- [display_status]
- [respond]

<details>

```
[virtual_sdcard]
path: ~/printer_data/gcodes
on_error_gcode: CANCEL_PRINT

[pause_resume]

[display_status]

[respond]

```

</details>

Des «aides»

<details>

```
# Usage: SET_PAUSE_NEXT_LAYER [ENABLE=[0 | 1]] [MACRO=<name>]
[gcode_macro SET_PAUSE_NEXT_LAYER]
description: Enable a pause if the next layer is reached
gcode:
  {% set pause_next_layer = printer['gcode_macro SET_PRINT_STATS_INFO'].pause_next_layer %}
  {% set ENABLE = params.ENABLE | default(1) | int != 0 %}
  {% set MACRO = params.MACRO | default(pause_next_layer.call, True) %}
  SET_GCODE_VARIABLE MACRO=SET_PRINT_STATS_INFO VARIABLE=pause_next_layer VALUE="{{ 'enable': ENABLE, 'call': MACRO }}"

# Usage: SET_PAUSE_AT_LAYER [ENABLE=[0 | 1]] [LAYER=<number>] [MACRO=<name>]
[gcode_macro SET_PAUSE_AT_LAYER]
description: Enable/disable a pause if a given layer number is reached
gcode:
  {% set pause_at_layer = printer['gcode_macro SET_PRINT_STATS_INFO'].pause_at_layer %}
  {% set ENABLE = params.ENABLE | int != 0 if params.ENABLE is defined
             else params.LAYER is defined %}
  {% set LAYER = params.LAYER | default(pause_at_layer.layer) | int %}
  {% set MACRO = params.MACRO | default(pause_at_layer.call, True) %}
  SET_GCODE_VARIABLE MACRO=SET_PRINT_STATS_INFO VARIABLE=pause_at_layer VALUE="{{ 'enable': ENABLE, 'layer': LAYER, 'call': MACRO }}"

# Usage: SET_PRINT_STATS_INFO [TOTAL_LAYER=<total_layer_count>] [CURRENT_LAYER= <current_layer>]
[gcode_macro SET_PRINT_STATS_INFO]
rename_existing: SET_PRINT_STATS_INFO_BASE
description: Overwrite, to get pause_next_layer and pause_at_layer feature
variable_pause_next_layer: { 'enable': False, 'call': "PAUSE" }
variable_pause_at_layer  : { 'enable': False, 'layer': 0, 'call': "PAUSE" }
gcode:
  {% if pause_next_layer.enable %}
    RESPOND TYPE=echo MSG='{"%s, forced by pause_next_layer" % pause_next_layer.call}'
    {pause_next_layer.call} ; execute the given gcode to pause, should be either M600 or PAUSE
    SET_PAUSE_NEXT_LAYER ENABLE=0
  {% elif pause_at_layer.enable and params.CURRENT_LAYER is defined and params.CURRENT_LAYER | int == pause_at_layer.layer %}
    RESPOND TYPE=echo MSG='{"%s, forced by pause_at_layer [%d]" % (pause_at_layer.call, pause_at_layer.layer)}'
    {pause_at_layer.call} ; execute the given gcode to pause, should be either M600 or PAUSE
    SET_PAUSE_AT_LAYER ENABLE=0
  {% endif %}
  SET_PRINT_STATS_INFO_BASE {rawparams}

```
 
</details>

Ces macros dont le nom débute par le caractère souligné « _ » sont des aides pour les autres macros et ne doivent pas être modifiées.

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
- soit placer la directive `include` après ces macros G-Code (si / quand une macro portant le même nom est rencontré, c'est la dernière lue qui l'emporte),
- soit encore scinder le `printer.cfg` en deux (voir [Ma configuration](./MyConfiguration.md))

Plus d'informations [Fluidd-config](https://github.com/fluidd-core/fluidd-config) ou [Mainsail-config](https://github.com/mainsail-crew/mainsail-config)

### QIDI TECH

**La version Qidi de Klipper étant ancienne (basée sur une version 0.10), l'inclusion telle quelle du fichier `client.cfg` empêche
le bon démarrage de Klipper (`SET_PRINT_STATS_INFO` n'est pas reconnu comme Gcode)**.

Solution :

1. Ne pas inclure ce fichier
2. Hacker le fichier client.cfg ( ***ce fichier étant en lecture seule, on ne peut le modifier directement dans Fluidd*** ) :
    - en utilisateur `root` via ssh :
        - Ajouter un dièse ( # ) au début de la ligne `rename_existing` de la macro `SET_PRINT_STATS_INFO`
        ```
        [gcode_macro SET_PRINT_STATS_INFO]
        #rename_existing: SET_PRINT_STATS_INFO_BASE
        description: Overwrite, to get pause_next_layer and pause_at_layer feature
        ```
