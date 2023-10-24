
### Moonraker.conf

Il faut ajouter une section `[power …]` au fichier `moonraker.conf`. Le contenu de cette section dépend du type de prise connectée [documentation](https://moonraker.readthedocs.io/en/latest/configuration/#power)
```
## Gestion prise électrique via Tasmota
[power Qidi_XMax3]
type: tasmota
address: 192.168.1.186
```
### Macros

Seule la macro `POWER_OFF_PRINTER` est utilisable, la carte Qidi Tech faisant à la fois office d'ordinateur monocarte (Small Board Computer (SBC))
et de carte pilotant le matériel, après extinction, on ne peut plus piloter la prise connectée.

L'imprimante s'éteint automatiquement après un délai d'inactivité de 15 minutes.

<details>
  ```
#=====================================================
# Power Operations / HA Plug
#=====================================================
[gcode_macro POWER_ON_PRINTER]
gcode:
  {action_call_remote_method("set_device_power",
                             device="Qidi_XMax3",
                             state="on")}
  
[gcode_macro POWER_OFF_PRINTER]
gcode:
  {action_call_remote_method("set_device_power",
                             device="Qidi_XMax3",
                             state="off")}
  
[delayed_gcode delayed_printer_off]
initial_duration: 0.
gcode:
  {% if printer.idle_timeout.state != "Printing" %}
    POWER_OFF_PRINTER
  {% endif %}
  
[idle_timeout]
gcode:
  M84 ; disable steppers
  TURN_OFF_HEATERS
  UPDATE_DELAYED_GCODE ID=delayed_printer_off DURATION=900
  
  ```
</details>

