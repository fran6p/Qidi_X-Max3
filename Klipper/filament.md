### Gestion du filament

Deux macros permettant d'activer et désactiver le détecteur de fin de filament
```
[gcode_macro _DISABLE_FS]
description: disables filament sensor that might trigger an M600 in the middle of a load/unload/M600...
gcode:
    SET_FILAMENT_SENSOR SENSOR=fila ENABLE=0

[gcode_macro _ENABLE_FS]
description: enables filament sensor
gcode:
    SET_FILAMENT_SENSOR SENSOR=fila ENABLE=1
```

#### Aide au déchargement du filament

Utilise la macro M603 de Qidi Tech (correspond à l'écran au déchargement du filament) qui «forme» la pointe du filament
en extrudant d'abord une petite quantié puis en extrayant le filament juste au-dessus des deux roues dentées d'entrainement
de l'extrudeur. 

Pour facilier ensuite la réintroduction de filament, il vaut mieux retirer le PTFE de la tête.
```
[gcode_macro UNLOAD_FILAMENT]
description: Unloads Filament from extruder
gcode:
  {% if printer.extruder.temperature < 180 %}
    {action_respond_info("Extruder temperature too low")}
  {% else %}
    SAVE_GCODE_STATE NAME=UNLOAD_state
    {% set Z = params.Z|default(50)|int %}
    {% set axis_max = printer.toolhead.axis_maximum %}
    {% set pos = printer.toolhead.position %}
    {% set z_diff = axis_max.z - pos.z %}
    {% set z_safe_lift = [ Z, z_diff ] | min%}
    G91                   # relative positioning
    G0 Z{ z_safe_lift }
    # Reset extruder position
    G92 E0
    M603 # Qidi macro unload filament
    RESTORE_GCODE_STATE NAME=UNLOAD_state
  {% endif %}
```

Une fois le filament réinséré, permet de purger autant que nécessaire le filament (50mm par défaut).
``` 
[gcode_macro PURGE_FILAMENT]
description: Extrudes filament, used to clean out previous filament
gcode:
  {% if printer.extruder.temperature < 180 %}
    {action_respond_info("Extruder temperature too low")}
  {% else %}
    {% set PURGE_AMOUNT = params.PURGE_AMOUNT|default(50)|float %}
    SAVE_GCODE_STATE NAME=PURGE_state
    G91                   # relative positioning
    G1 E{PURGE_AMOUNT} F{ 5 * 60 }  # purge
    RESTORE_GCODE_STATE NAME=PURGE_state
  {% endif %}
```

Macro minimale permettant le changement de couleur (M600 à insérer via le trancheur) :
- vérifie que l'extrudeur est en capacité d'extruder du filament (température ⩾ 180°C)
- met en pause (parque la tête via la macro PAUSE, cf. client.cfg)
- désactive le détecteur de filament
- décharge le filament
  
``` 
[gcode_macro M600]
description: Starts process of Filament Change
gcode:
  {% if printer.extruder.temperature < 180 %}
    {action_respond_info("Extruder temperature too low")}
  {% else %}
    PAUSE_MACRO
    _DISABLE_FS
    UNLOAD_FILAMENT
  {% endif %}
```

Appelle la macro PAUSE du client.cfg (Fluidd / Mainsail) et modifie le délai d'attente à 30 minutes
```
[gcode_macro PAUSE_MACRO]
description: Pauses Print
gcode:
    PAUSE
    SET_IDLE_TIMEOUT TIMEOUT={ 30 * 60 }  # 30 minutes
```

