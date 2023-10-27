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
gcode:
    {% set S = params.S|default(1000)|int %} ; S sets the tone frequency
    {% set P = params.P|default(100)|int %} ; P sets the tone duration
    {% set L = 0.5 %} ; L varies the PWM on time, close to 0 or 1 the tone gets a bit quieter. 0.5 is a symmetric waveform
    {% if S <= 0 %} ; dont divide through zero
        {% set F = 1 %}
        {% set L = 0 %}
    {% elif S >= 10000 %} ;max frequency set to 10kHz
        {% set F = 0 %}
    {% else %}
        {% set F = 1/S %} ;convert frequency to seconds
    {% endif %}
    SET_PIN PIN=beeper VALUE={L} CYCLE_TIME={F} ;Play tone
    G4 P{P} ;tone duration
    SET_PIN PIN=beeper VALUE=0
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

…
