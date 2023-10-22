## MACROS ADDITIONNELLES


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

#       ZIPPY (rootiest)       #
#[include macros/zippy/bed_leveling.cfg]
#[include macros/zippy/shaping.cfg]
#[include macros/zippy/smart-m600.cfg]
#[include macros/zippy/sensorless_homing_override.cfg]
[include macros/zippy/get_probe_limits.cfg]
[include macros/zippy/test_speed.cfg]
[include macros/zippy/tunes.cfg]
[include macros/zippy/zippystats.cfg]

#        QIDI TECH macros      #
[include macros/qidi_macros.cfg]
#        MARLIN G-CODE         #
#[include macros/heater_override.cfg]
#[include macros/marlin_macros.cfg]
#            HOMING            #
[include macros/homing_alternate.cfg]
#       SHUTDOWN / REBOOT      #
[include macros/HA_power_macros.cfg]
#           FILAMENT            #
#[include macros/filament.cfg]
#         SHELL_COMMAND         #
[include macros/shell_command.cfg]
#        PID HOTEND / BED       #
[include macros/pid.cfg]
#           Variables           #
[include macros/save_variables.cfg]
#      Hotend Tool Head         #
#[include macros/MKS_THR.cfg]
#    Client Fluidd / Mainsail   #
[include client.cfg]
#      TIMELAPSE PLUGIN         #
[include timelapse.cfg]
# Klipper Adaptative Mesh Purge #
[include Adaptive_Mesh.cfg]
```
