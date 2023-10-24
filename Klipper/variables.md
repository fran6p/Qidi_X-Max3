La macro [save_variables.cfg](./MyConfiguration/macros/save_variables.cfg) débute par la section [save_variables]
qui précise le nom complet (chemin d'accès inclus) du fichier où seront enregistrées les variables persistantes.

Qidi Tech ne stocke pas, par exemple, le Zoffset en fin du fichier `printer.cfg` dans la section #*# DO NOT EDIT … mais
dans le fichier de configuration de l'écran `config.mksini` dans la section [babystep]. Ce réglage doit être réalisé uniquement via l'écran 
de l'imprimante 🙁

Avec cette macro, la valeur du Zoffset est également préservée dans le fichier `variables.cfg`

<details>
  
```
# Useful parameters and macros
[save_variables]
filename: /home/mks/klipper_config/variables.cfg

[respond]

[gcode_macro SET_GCODE_OFFSET]
description: Saving Z-Offset
rename_existing: _SET_GCODE_OFFSET
gcode:
  {% if printer.save_variables.variables.zoffset %}
    {% set zoffset = printer.save_variables.variables.zoffset %}
  {% else %}
    {% set zoffset = {'z': None} %}
  {% endif %}
  {% set ns = namespace(zoffset={'z': zoffset.z}) %}
  _SET_GCODE_OFFSET {% for p in params %}{'%s=%s '% (p, params[p])}{% endfor %}
  {%if 'Z' in params %}{% set null = ns.zoffset.update({'z': params.Z}) %}{% endif %}
  {%if 'Z_ADJUST' in params %}
    {%if ns.zoffset.z == None %}{% set null = ns.zoffset.update({'z': 0}) %}{% endif %}
      {% set null = ns.zoffset.update({'z': (ns.zoffset.z | float) + (params.Z_ADJUST | float)}) %}
  {% endif %}
  SAVE_VARIABLE VARIABLE=zoffset VALUE="{ns.zoffset}"

[delayed_gcode LOAD_GCODE_OFFSETS]
initial_duration: 2
gcode:
  {% if printer.save_variables.variables.zoffset %}
    {% set zoffset = printer.save_variables.variables.zoffset %}
    _SET_GCODE_OFFSET {% for axis, offset in zoffset.items() if zoffset[axis] %}{ "%s=%s " % (axis, offset) }{% endfor %}
    { action_respond_info("Z-Offset loaded from variables.cfg file: %s" % (zoffset)) }
  {% endif %}
```

</details>

D'autres macros pourront utiliser le fichier `variables.cfg` pour y enregistrer leurs valeurs.
