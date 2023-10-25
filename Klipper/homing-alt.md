### Mise à l'origine sous condition

Les macros _HOME_CHECK, _CG28, LAZY_HOME, HOME_IF_NEEDED et CHECK_HOME réalisent la même chose :
- **Vérifie si l'imprimante a été mise à l'origine, si ce n'est pas le cas, met l'imprimante à l'origine en utilisant le Gcode G28**

```
# Conditional homing
[gcode_macro  _HOME_CHECK]
description: Checks if the printer is homed, if not then homes the printer
gcode:
  {% if printer.toolhead.homed_axes != "xyz" %}
    G28
  {% endif %}

[gcode_macro _CG28]
gcode:
    _HOME_CHECK { rawparams }

[gcode_macro LAZY_HOME]
gcode:
    _HOME_CHECK { rawparams }

[gcode_macro HOME_IF_NEEDED]
gcode:
    _HOME_CHECK { rawparams }

[gcode_macro CHECK_HOME]
gcode:
    _HOME_CHECK { rawparams }
```
