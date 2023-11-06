## Gcodes «Marlin»

- [M205](./MyConfiguration/macros/marlin_macros.cfg)

```
#########################################
#              Square corner            #
#########################################
[gcode_macro M205]
gcode:
  {% if 'X' in params %}
    SET_VELOCITY_LIMIT SQUARE_CORNER_VELOCITY={params.X}
  {% elif 'Y' in params %}
    SET_VELOCITY_LIMIT SQUARE_CORNER_VELOCITY={params.Y}
  {% endif %}
```

- [M300](./MyConfiguration/macros/marlin_macros.cfg)

```
# Used for beep tones
[gcode_macro M300]
# Use Qidi's macro BEEP slightly modified
gcode:
  BEEP_ON # activate «beeper»
  {% set i = params.I|default(1)|int %}        ; Iterations (number of times to beep).
    {% set dur = params.DUR|default(100)|int %}  ; Duration/wait of each beep in ms. Default 100ms.

    {% if printer["output_pin sound"].value|int == 1 %}
        {% for iteration in range(i|int) %}
            SET_PIN PIN=beeper VALUE=1
            G4 P{dur}
            SET_PIN PIN=beeper VALUE=0
    		G4 P{dur}
        {% endfor %}
    {% endif %}
```

- [M109, M190, M104, M140](./MyConfiguration/macros/heater_override.cfg)

```
# Replace M109/M190 with TEMPERATURE_WAIT commands

[gcode_macro M109]
rename_existing: M99109
gcode:
    #Parameters
    {% set s = params.S|float %}
    #Active extruder
    {% set t = printer.toolhead.extruder %}
    
    M104 {rawparams}  ; Set hotend temp
    {% if s != 0 %}
        TEMPERATURE_WAIT SENSOR={t} MINIMUM={s} MAXIMUM={s+1}   ; Wait for hotend temp (within 1 degree)
    {% endif %}

[gcode_macro M190]
rename_existing: M99190
gcode:
    #Parameters
    {% set s = params.S|float %}

    M140 {rawparams}   ; Set bed temp
    {% if s != 0 %}
        TEMPERATURE_WAIT SENSOR=heater_bed MINIMUM={s} MAXIMUM={s+1}  ; Wait for bed temp (within 1 degree)
    {% endif %}

[gcode_macro M104]
rename_existing: M99104
gcode:
    #Parameters
    {% set s = params.S|float %}
    #Active extruder
    {% set t = printer.toolhead.extruder %}

    SET_HEATER_TEMPERATURE HEATER={t} TARGET={s}

[gcode_macro M140]
rename_existing: M99140
gcode:
    #Parameters
    {% set s = params.S|float %}
    SET_HEATER_TEMPERATURE HEATER=heater_bed TARGET={s}
```

- [M191](./MyConfiguration/macros/heater_override.cfg)

Si le nom de la chambre est toujours celui de Qidi `hot`, remplacer le nom `chamber` dans la ligne `TEMPERATUR_WAIT_SENSOR` :smirk:

```
# Add M191 with TEMPERATURE_WAIT commands
[gcode_macro M191]
gcode:
    #Parameters
    {% set s = params.S|float %}
    M141 {% for p in params %}{'%s%s' % (p, params[p])}{% endfor %}  ; Set chamber temp
    {% if s != 0 %}
        TEMPERATURE_WAIT SENSOR="heater_generic chamber" MINIMUM={s} MAXIMUM={s+1}   ; Wait for chamber temp (within 1 degree)
    {% endif %}
```

…
