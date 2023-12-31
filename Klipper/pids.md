Macros facilitant la calibration des PIDs de la tête (**PID_EXTRUDER**) et du lit chauffant (**PID_BED**)

Chacune des macros peut être appelée sans paramètre additionnel mais on peut toutefois préciser la température ciblée

Exemple :
```
PID_EXTRUDER
```
Pour effectuer un étalonnage de la tête avec les valeurs par défaut (temp=210°C, ventilateur filament=0)

```
PID_EXTRUDER TEMPERATURE=240 FAN_IN_PERCENT=75
```
Pour effectuer un étalonnage de la tête à 240°C avec refroissement filament à 75%

```
######### PID_EXTRUDER #########
[gcode_macro PID_EXTRUDER]
description: PID Tune for the Extruder
gcode:
  {% set e = printer.toolhead.extruder %}
  {% set T = params.TEMPERATURE|default(210)|float %}
  {% set S = params.FAN_IN_PERCENT|default(0)|float *2.55 %}
  {% set P = printer.configfile.config[e].pid_kp|float %}
  {% set I = printer.configfile.config[e].pid_ki|float %}
  {% set D = printer.configfile.config[e].pid_kd|float %}
  M106 S{S}
  M118 // PID parameters: pid_Kp={P} pid_Ki={I} pid_Kd={D}  (old)
  PID_CALIBRATE HEATER={e} TARGET={T}
  TURN_OFF_HEATERS
  SAVE_CONFIG

############ PID_BED ###########
[gcode_macro PID_BED]
description: PID Tune for the Bed
gcode:
  {% set T = params.TEMPERATURE|default(60)|float %}
  {% set P = printer.configfile.config['heater_bed'].pid_kp|float %}
  {% set I = printer.configfile.config['heater_bed'].pid_ki|float %}
  {% set D = printer.configfile.config['heater_bed'].pid_kd|float %}
  M118 // PID parameters: pid_Kp={P} pid_Ki={I} pid_Kd={D}  (old)
  PID_CALIBRATE HEATER=heater_bed TARGET={T}
  TURN_OFF_HEATERS
  SAVE_CONFIG
 
```

Qidi Tech dans ses macros fourni un `M303`

```
[gcode_macro M303]
gcode:
  {% if params.E is defined %}
    {% if params.S is defined %}
      {% if (params.E|int)==-1 %} 
        PID_CALIBRATE HEATER=heater_bed TARGET={params.S|int}
      {% endif %}
      {% if (params.E|int)==0 %}
        PID_CALIBRATE HEATER=extruder TARGET={params.S|int}
      {% endif %}
    {% endif %}
  {% endif %}
```

On peut réaliser l'étalonnage des PID via :
- `M303 E0 S250` (pour la tête à 250°C)
- `M303 E-1 S85` (pour le lit chauffant à 85°C)


