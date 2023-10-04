Les fichiers de configuration que j'utilise avec ma Ender3 S1

Le printer.cfg expurgé des macros «Creality» (configuration matérielle seule) :

<details>
  <summary>(Cliquez pour agrandir!)</summary>


```
# !Ender-3 S1
# printer_size: 230x230x270
# v2.7
# Motherboard (Late 2020/2021) as the heater pins changed.
# To use this config, during "make menuconfig" select the STM32F103
# with a "28KiB bootloader" and serial (on USART1 PA10/PA9)
# communication.

# Flash this firmware by copying "out/klipper.bin" to a SD card and
# turning on the printer with the card inserted. The firmware
# filename must end in ".bin" and must not match the last filename
# that was flashed.

# See docs/Config_Reference.md for a description of parameters.

####################################################################
#   ____             __ _                       _   _              #
#  / ___|___  _ __  / _(_) __ _ _   _ _ __ __ _| |_(_) ___  _ __   #
# | |   / _ \| '_ \| |_| |/ _` | | | | '__/ _` | __| |/ _ \| '_ \  #
# | |__| (_) | | | |  _| | (_| | |_| | | | (_| | |_| | (_) | | | | #
#  \____\___/|_| |_|_| |_|\__, |\__,_|_|  \__,_|\__|_|\___/|_| |_| #
#                         |___/                                    #
#                                                                  #
####################################################################

#======================== Included Configurations ==================
[include webinterface.cfg]
[include timelapse.cfg]
[include macros.cfg]
[include shell_command.cfg]

#======================= Common Kinematic Settings =================
[printer]
kinematics: cartesian
max_velocity: 300
max_accel: 2500
# max_accel_to_decel: 7000
max_z_velocity: 10
square_corner_velocity: 5.0
max_z_accel: 1000

[stepper_x]
step_pin: PC2
dir_pin: PB9
enable_pin: !PC3
microsteps: 16
rotation_distance: 40
endstop_pin: !PA5
position_min: -3
position_endstop: -3
position_max: 247
homing_speed: 80

[stepper_y]
step_pin: PB8
dir_pin: PB7
enable_pin: !PC3
microsteps: 16
rotation_distance: 40
endstop_pin: !PA6
position_min: -2
position_endstop: -2
position_max: 232 # 230
homing_speed: 80

[stepper_z]
step_pin: PB6
dir_pin: !PB5
enable_pin: !PC3
microsteps: 16
rotation_distance: 8
endstop_pin: probe:z_virtual_endstop
position_max: 270
position_min: -5
homing_speed: 6
second_homing_speed: 1
homing_retract_dist: 2.0

#=========================  Extruder and Heated Bed  ===============
[extruder]
max_extrude_only_distance: 1000.0
step_pin: PB4
dir_pin: PB3
enable_pin: !PC3
microsteps: 16
#gear_ratio: 42:12 # = 3.5:1
#rotation_distance: 26.6665
rotation_distance: 7.6190 # sans gear_ratio
nozzle_diameter: 0.400
filament_diameter: 1.750
heater_pin: PA1
sensor_type: EPCOS 100K B57560G104F
sensor_pin: PC5
#control: pid
#pid_Kp: 23.904
#pid_Ki: 1.476
#pid_Kd: 96.810
min_temp: 0
max_temp: 300 # 265
#max_extrude_cross_section: 2.0 # 0.64 ( 4 x nozzle_dia x nozzle_dia )
#pressure_advance: 0.038 # Eryone PLa Matte black
pressure_advance: 0.017 # PLA 3D850 Charcoal black
pressure_advance_smooth_time: 0.040

[heater_bed]
heater_pin: PA7
sensor_type: EPCOS 100K B57560G104F
sensor_pin: PC4
#control: pid
#pid_Kp: 74.000
#pid_Ki: 1.965
#pid_Kd: 696.525
min_temp: 0
max_temp: 120 # 130

[verify_heater extruder]
check_gain_time: 200
hysteresis: 5

#============================= Filament Sensors ====================
[filament_switch_sensor filament_sensor]
pause_on_runout: true
runout_gcode: M600
switch_pin: ^!PC15

#=================================== Fans ==========================
[heater_fan hotend_fan]
pin: PC0
heater: extruder
heater_temp: 50.0
max_power: 0.8
shutdown_speed: 0
fan_speed: 1.0

[fan]
pin: PA0
kick_start_time: 0.5

#========================== Micro-Controller Config ================
[mcu]
serial: /dev/serial/by-id/usb_serial_1
#serial: /dev/serial/by-id/usb-1a86_USB_Serial-if00-port0
restart_method: command

#[mcu rpi]
#serial: /tmp/klipper_host_mcu

#==================  Temperatures host + μcontroler =================
[temperature_sensor SonicPad]
sensor_type: temperature_host
min_temp: 10
max_temp: 75

[temperature_sensor STM32F103]
sensor_type: temperature_mcu
min_temp: 10
max_temp: 75

#==========================  Resonance Measurement  =================
[input_shaper]
#shaper_freq_x: 59.6
#shaper_freq_y: 44.2
#shaper_type_x: 2hump_ei
#shaper_type_y: ei

#[adxl345]
#cs_pin: rpi:None
#spi_speed: 2000000
#spi_bus: spidev2.0

#[resonance_tester]
#accel_chip: adxl345
#accel_per_hz: 70
#probe_points:
#    117.5,117.5,10

#============================= Probing Harware =====================
# Before printing the PROBE_CALIBRATE command needs to be issued at
# least once to run the probe calibration procedure, described at 
# docs/Probe_Calibrate.md, to find the correct z_offset.
[bltouch]
sensor_pin: ^PC14
control_pin: PC13
x_offset: -31.8 # -30
y_offset: -40.5 # -40
#z_offset: 0
speed: 10
samples: 1
samples_result: average
probe_with_touch_mode: true
stow_on_each_sample: false

#================================ Safe Homing ======================
[safe_z_home]
home_xy_position: 145,155 # 147, 154
speed: 200
z_hop: 10
z_hop_speed: 10
#move_to_previous: true

#============================= Bed Level Support ===================
[bed_mesh]
speed: 200 # 120
mesh_min: 10, 10 #15,30 # 20, 20
mesh_max: 214, 190 #210,190 # 200, 197
mesh_pps: 2,2
algorithm: bicubic
probe_count: 9,9 #7,7 #5,5

[bed_screws]
screw1: 25, 30
screw2: 210, 30
screw3: 210, 200
screw4: 25, 200

[screws_tilt_adjust]
screw1: 57, 70 # x+32, y+40
screw1_name: front left screw
screw2: 237, 70
screw2_name: front right screw
screw3: 237, 231 # 240 out of range, 232 noise
screw3_name: rear right screw
screw4: 57, 231 # 240 out of range, 232 noise
screw4_name: rear left screw
horizontal_move_z: 4.0
speed: 100
screw_thread: CW-M4 # CW for Clockwise, CCW for Counter Clockwise

#=========================== Optional Features =====================
[respond] 

[firmware_retraction]
retract_length: .4
retract_speed: 40
unretract_extra_length: 0.0
unretract_speed: 35

# Support for gcode arc (G2/G3) commands.
[gcode_arcs]
resolution: 1.0

[save_variables]
# Support saving variables to disk so that they are retained across
# restarts.
filename: /mnt/UDISK/printer_config/variables.cfg
#   Required - provide a filename that would be used to save the
#   variables to disk e.g. ~/variables.cfg

#*# <---------------------- SAVE_CONFIG ---------------------->
#*# DO NOT EDIT THIS BLOCK OR BELOW. The contents are auto-generated.
#*#
#*# [bed_mesh default]
#*# version = 1
#*# points =
#*# 	  0.092500, 0.072500, 0.040000, 0.030000, 0.042500, 0.025000, 0.027500, 0.020000, 0.002500
#*# 	  0.022500, 0.020000, -0.030000, -0.007500, 0.012500, -0.005000, 0.002500, 0.007500, -0.010000
#*# 	  -0.017500, -0.002500, -0.057500, -0.030000, 0.005000, 0.002500, 0.027500, 0.040000, 0.062500
#*# 	  -0.067500, -0.057500, -0.090000, -0.057500, -0.015000, 0.020000, 0.067500, 0.077500, 0.057500
#*# 	  -0.042500, -0.032500, -0.082500, -0.055000, -0.020000, -0.022500, 0.020000, 0.042500, 0.060000
#*# 	  -0.037500, -0.040000, -0.082500, -0.052500, -0.020000, -0.017500, 0.020000, 0.050000, 0.067500
#*# 	  -0.067500, -0.065000, -0.107500, -0.077500, -0.042500, -0.037500, 0.012500, 0.050000, 0.092500
#*# 	  -0.027500, -0.045000, -0.097500, -0.072500, -0.042500, -0.042500, -0.005000, 0.032500, 0.060000
#*# 	  -0.062500, -0.082500, -0.140000, -0.117500, -0.085000, -0.085000, -0.040000, -0.005000, 0.035000
#*# tension = 0.2
#*# min_x = 10.0
#*# algo = bicubic
#*# y_count = 9
#*# mesh_y_pps = 2
#*# min_y = 10.0
#*# x_count = 9
#*# max_y = 190.0
#*# mesh_x_pps = 2
#*# max_x = 214.0
#*#
#*# [extruder]
#*# control = pid
#*# pid_kp = 22.703
#*# pid_ki = 1.201
#*# pid_kd = 107.271
#*#
#*# [heater_bed]
#*# control = pid
#*# pid_kp = 70.991
#*# pid_ki = 1.283
#*# pid_kd = 982.342
#*#
#*# [input_shaper]
#*# shaper_type_x = ei
#*# shaper_freq_x = 43.4
#*# shaper_type_y = 2hump_ei
#*# shaper_freq_y = 44.0
#*#
#*# [bltouch]
#*# z_offset = 1.510
```

 </details>
  
Les macros regroupées dans un fichier séparé à inclure (voir le début du fichier printer.cfg) :

<details>
  <summary>(Cliquez pour agrandir!)</summary>


```
#================== MACROS fluidd / mainsail (Web interfaces) ===================
[gcode_macro PAUSE]
description: Pause the actual running print
rename_existing: PAUSE_BASE
# change this if you need more or less extrusion
variable_extrude: 1.0
gcode:
  ##### read E from pause macro #####
  {% set E = printer["gcode_macro PAUSE"].extrude|float %}
  ##### set park positon for x and y #####
  # default is your max posion from your printer.cfg
  {% set x_park = printer.toolhead.axis_maximum.x|float - 5.0 %}
  {% set y_park = printer.toolhead.axis_maximum.y|float - 5.0 %}
  ##### calculate save lift position #####
  {% set max_z = printer.toolhead.axis_maximum.z|float %}
  {% set act_z = printer.toolhead.position.z|float %}
  {% if act_z < (max_z - 2.0) %}
      {% set z_safe = 2.0 %}
  {% else %}
      {% set z_safe = max_z - act_z %}
  {% endif %}
  ##### end of definitions #####
  PAUSE_BASE
  G91
  {% if printer.extruder.can_extrude|lower == 'true' %}
    G1 E-{E} F2100
  {% else %}
    {action_respond_info("Extruder not hot enough")}
  {% endif %}
  {% if "xyz" in printer.toolhead.homed_axes %}
    G1 Z{z_safe} F900
    G90
    G1 X{x_park} Y{y_park} F6000
  {% else %}
    {action_respond_info("Printer not homed")}
  {% endif %}

[gcode_macro RESUME]
description: Resume the actual running print
rename_existing: RESUME_BASE
gcode:
  ##### read E from pause macro #####
  {% set E = printer["gcode_macro PAUSE"].extrude|float %}
  #### get VELOCITY parameter if specified ####
  {% if 'VELOCITY' in params|upper %}
    {% set get_params = ('VELOCITY=' + params.VELOCITY)  %}
  {%else %}
    {% set get_params = "" %}
  {% endif %}
  ##### end of definitions #####
  {% if printer.extruder.can_extrude|lower == 'true' %}
    G91
    G1 E{E} F2100
  {% else %}
    {action_respond_info("Extruder not hot enough")}
  {% endif %}
  RESUME_BASE {get_params}

[gcode_macro CANCEL_PRINT]
description: Cancel the actual running print
rename_existing: CANCEL_PRINT_BASE
gcode:
  TURN_OFF_HEATERS
  {% if "xyz" in printer.toolhead.homed_axes %}
    G91
    G1 Z4.5 F300
    G90
  {% else %}
    {action_respond_info("Printer not homed")}
  {% endif %}
    G28 X Y
  {% set y_park = printer.toolhead.axis_maximum.y|float - 5.0 %}
    G1 Y{y_park} F2000
    M84
  CANCEL_PRINT_BASE

#===========================================================================
#========================= Start Print & End Print =========================
#===========================================================================
[gcode_macro START_PRINT]
description: Use START_PRINT for the slicer beginning script
  Customize for your slicer of choice with placeholders. These are different
  for slicers, so take care of their syntax.
gcode:
      # Get Printer built volume dimensions
      {% set X_MAX = printer.toolhead.axis_maximum.x|default(235)|float %}
      {% set Y_MAX = printer.toolhead.axis_maximum.y|default(235)|float %}
      {% set Z_MAX = printer.toolhead.axis_maximum.z|default(270)|float %}
      # Get Nozzle diameter and filament width for conditioning
      {% set NOZZLE = printer.extruder.nozzle_diameter|default(0.4)|float %}
      {% set FILADIA = printer.extruder.filament_diameter|default(1.75)|float %}
      # Set Start coordinates of purge lines
      {% set X_START = 4.0|default(4.0)|float %}
      {% set Y_START = 9.0|default(9.0)|float %}
      # Calculate purge line extrusion volume and filament length
      {% set PRIMER_WIDTH = 1 * NOZZLE %}                    
      {% set PRIMER_HEIGHT = 0.5 * NOZZLE %}           
      {% set PRIMER_SECT = PRIMER_WIDTH * PRIMER_HEIGHT %}    
      {% set PRIMER_VOL = PRIMER_SECT * (Y_MAX - 3 - Y_START) * 2 %}    
      {% set FILA_SECT = 3.1415 * ( FILADIA / 2.0) * ( FILADIA / 2.0) %}          
      {% set FILA_LENGTH = 1.55 * PRIMER_VOL / FILA_SECT %}      
      # Get Bed and Extruder temperature from Slicer GCode
      {% set BED_TEMP = params.BED_TEMP|default(60)|float %}
      {% set EXTRUDER_TEMP_PRE = 160|float %}
      {% set EXTRUDER_TEMP = params.EXTRUDER_TEMP|default(205)|float %}
      # Preheat nozzle and bed
      M104 S{EXTRUDER_TEMP_PRE}                        
      M190 S{BED_TEMP}
      # Reset Pressure Advance to 0, will be adjusted later in G-code based on material settings from Cura
      #M900 K0
      # Reset the G-Code Z offset (adjust Z offset if needed)
      SET_GCODE_OFFSET Z=0.0
      # Home
      _CG28
      # Arrêt de l'impression si le lit a bougé
      SCREWS_TILT_CALCULATE MAX_DEVIATION=0.1 
      # either use one of these below lines : G29 and / or BED_MESH_CALIBRATE
      # do bed leveling for each print.
      # BED_MESH_PROFILE use an already made leveling.
      #G29
      #BED_MESH_CALIBRATE
      BED_MESH_PROFILE LOAD="default"
      #LEVEL_BED_ADVANCED MAX_AGE=10 ; probe mesh eventually
      # Park nozzle while things heat up
      G1 X{X_START} Y{Y_START-5} Z{PRIMER_HEIGHT} F6000.0                 
      # Heat nozzle and bed
      M190 S{BED_TEMP}                               
      M109 S{EXTRUDER_TEMP}                       
      # Purge line
      G90
      G92 E0     
      G1 X{X_START} Y{Y_START} Z{PRIMER_HEIGHT} F6000.0     
      G1 X{X_START} Y{Y_MAX - 3 - Y_START} Z{PRIMER_HEIGHT} E{FILA_LENGTH} F2000.0 
      G1 X{X_START + PRIMER_WIDTH} Y{Y_MAX - 3 - Y_START} Z{PRIMER_HEIGHT} 
      G1 X{X_START + PRIMER_WIDTH} Y{Y_START} Z{PRIMER_HEIGHT} E{FILA_LENGTH*2} F2000.0 
      G92 E0            
      G1 Z2.0 F600        
      G1 Z0.2 F600        
      G1 Z2.0 F600

[gcode_macro END_PRINT]
description: Use END_PRINT for the slicer ending script - customize for your slicer of choice
gcode:
    M400                           ; wait for buffer to clear
    G92 E0                         ; zero the extruder
    G1 E-3.0 F3600                 ; retract filament
    G91                            ; relative positioning
    #   Get Boundaries
    {% set X_MIN = printer.toolhead.axis_minimum.x|default(0)|float %}
    {% set Y_MAX = printer.toolhead.axis_maximum.y|default(230)|float %}
    {% set max_z = printer.toolhead.axis_maximum.z|default(270)|float %}
    {% if printer.toolhead.position.z < (max_z - 2) %}
      {% set z_safe = 2.0 %}
    {% else %}
      {% set z_safe = max_z - printer.toolhead.position.z %}
    {% endif %}
    G0 Z{z_safe} F3600             ; move nozzle up and present print
    G90
    G0 X{X_MIN+2} Y{Y_MAX-5} F3600
    TURN_OFF_HEATERS
    M107                           ; turn off fan
    #G28 X Y
    M84                            ; Disable steppers
#    _SAVE_IF_SET     ; SAVE_CONFIG if a mesh was probed in START_PRINT (LEVEL_BED_ADVANCED)

# Alternative macros PRINT_START and PRINT_END
[gcode_macro PRINT_START]
gcode:
    START_PRINT { rawparams }

[gcode_macro PRINT_END]
gcode:
    END_PRINT { rawparams }

# This is where the magic happens:
#     MAX_AGE is checked against the stored variable
#     SAVE=1 can be used to force saving the mesh (restarts Klipper, so use only for manual usage)
#     FORCE_LEVEL=1 forces a mesh probe even if MAX_AGE is not reached
[gcode_macro LEVEL_BED_ADVANCED]
description: Levels the bed if the last leveling was MAX_AGE runs ago. Force leveling by setting FORCE_LEVEL to 1
variable_save_at_end: 0
gcode:
  {% set max_age = params.MAX_AGE|default(10)|int %}
  {% set force_level = params.FORCE|default(0)|int %}
  {% set save = params.SAVE|default(0)|int %}

  # load level_age from stored variables
  {% set svv = printer.save_variables.variables %}
  {% if "level_age" not in svv %} # first run
    SAVE_VARIABLE VARIABLE=level_age VALUE={max_age}
    {% set level_age = 1 %}
  {% else %} # load level_age and increment
    {% set level_age = svv.level_age %}
    SAVE_VARIABLE VARIABLE=level_age VALUE={level_age|int + 1}
  {% endif %}
  {action_respond_info("Bed mesh age is " + level_age|string) + "."} 

  # Level eventually
  {% if force_level or (level_age >= max_age|int) %}
    {action_respond_info("Bed mesh exceeded max age. Leveling...")} 

    # homing if not homed yet
    _CG28
    BED_MESH_CALIBRATE
    {% if save %}
      SAVE_VARIABLE VARIABLE=level_age VALUE=1 # reset counter
      SAVE_CONFIG
    {% else %}
      SET_GCODE_VARIABLE MACRO=LEVEL_BED_ADVANCED VARIABLE=save_at_end VALUE=1
    {% endif %}
  {% else %}
    {action_respond_info("Loading old bed mesh.")} 
    BED_MESH_PROFILE LOAD="default"
  {% endif %} 

#===========================================================================
#============================ Optional Macros ==============================
#===========================================================================

# Conditional homing
[gcode_macro _CG28]
gcode:
    {% if "xyz" not in printer.toolhead.homed_axes %}
        G28
    {% endif %}

# G29 => 
#    (1) home all 
#    (2) get bed mesh 
#    (3) move nozzle to corner, so it doesn't ooze on the bed while heating up.
[gcode_macro G29]
gcode:
  _CG28
  BED_MESH_CALIBRATE
  G0 X0 Y0 Z10 F6000
  #BED_MESH_PROFILE SAVE="ender3s1"

[gcode_macro ZUP]
description: Move Z up with babystep (0,01)
gcode:
  SET_GCODE_OFFSET Z_ADJUST=0.01 MOVE=1
	
[gcode_macro ZDOWN]
description: Move Z down with babystep (0,01)
gcode:
  SET_GCODE_OFFSET Z_ADJUST=-0.01 MOVE=1
	
[gcode_macro M900]
description: Set Pressure Advance
gcode:
    {% set K = params.K|default(0)|float %}
    SET_PRESSURE_ADVANCE ADVANCE={K}
	
[gcode_macro _SAVE_IF_SET]
description: runs SAVE_CONFIG if the g-code variable was set in start gcode
gcode:
  {% if printer["gcode_macro LEVEL_BED_ADVANCED"].save_at_end == 1 %}
  {action_respond_info("Saving was requested - saving and restarting now.")}
  SAVE_VARIABLE VARIABLE=level_age VALUE=1
  SAVE_CONFIG
  {% endif %}

[gcode_macro _DISABLE_FS]
description: disables filament sensor that might trigger an M600 in the middle of a load/unload/M600...
gcode:
    SET_FILAMENT_SENSOR SENSOR=filament_sensor ENABLE=0

[gcode_macro _ENABLE_FS]
description: enables filament sensor
gcode:
    SET_FILAMENT_SENSOR SENSOR=filament_sensor ENABLE=1

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
    G1 E5.0 F300         # extrude a little
    G1 E-50 F{ 10 * 60 } # perform the unload
    G1 E-50 F{ 5 * 60 }  # finish the unload
    RESTORE_GCODE_STATE NAME=UNLOAD_state
  {% endif %}
 
[gcode_macro PURGE_FILAMENT]
description: Extrudes filament, used to clean out previous filament
gcode:
  {% if printer.extruder.temperature < 180 %}
    {action_respond_info("Extruder temperature too low")}
  {% else %}
    {% set PURGE_AMOUNT = params.PURGE_AMOUNT|default(40)|float %}
    SAVE_GCODE_STATE NAME=PURGE_state
    G91                   # relative positioning
    G1 E{PURGE_AMOUNT} F{ 5 * 60 }  # purge
    RESTORE_GCODE_STATE NAME=PURGE_state
  {% endif %}
 
[gcode_macro LOAD_FILAMENT]
description: Loads filament into the extruder
gcode:
  {% if printer.extruder.temperature < 180 %}
    {action_respond_info("Extruder temperature too low")}
  {% else %}
    SAVE_GCODE_STATE NAME=LOAD_state
    G91                   # Relative positioning
    G1 E50 F{ 5 * 60 }    # extrude
    G4 P{ 0.9 * 1000 }    # dwell (ms)
    G1 E25.0 F{ 5 * 60 }  # extrude a little more
    _ENABLE_FS
    RESTORE_GCODE_STATE NAME=LOAD_state
  {% endif %}

[gcode_macro M600]
description: Starts process of Filament Change
rename_existing: M600.1
gcode:
  {% if printer.extruder.temperature < 180 %}
    {action_respond_info("Extruder temperature too low")}
  {% else %}
    PAUSE_MACRO
    _DISABLE_FS
    UNLOAD_FILAMENT
  {% endif %}

[gcode_macro PAUSE_MACRO]
description: Pauses Print
gcode:
    PAUSE
    SET_IDLE_TIMEOUT TIMEOUT={ 30 * 60 }  # 30 minutes
   
[gcode_macro  _HOME_CHECK]
description: Checks if the printer is homed, if not then homes the printer
gcode:
  {% if printer.toolhead.homed_axes != "xyz" %}
    G28
  {% endif %}
  
[gcode_macro PID_EXTRUDER]
description: PID Tune the Extruder
gcode:
  {% set TARGET_TEMP = params.TARGET_TEMP|default(210)|float %} 
  PID_CALIBRATE HEATER=extruder TARGET={TARGET_TEMP}
  TURN_OFF_HEATERS
  SAVE_CONFIG
 
[gcode_macro PID_BED]
description: PID Tune the Bed
gcode:
  {% set TARGET_TEMP = params.TARGET_TEMP|default(60)|float %} 
  PID_CALIBRATE HEATER=heater_bed TARGET={TARGET_TEMP}
  TURN_OFF_HEATERS
  SAVE_CONFIG
  
[gcode_macro BED_MESH]
description: Heats bed, makes a mesh and saves it
gcode:
  {% set BED_TEMP = params.BED_TEMP|default(60)|float %} 
  SET_HEATER_TEMPERATURE HEATER=heater_bed TARGET={BED_TEMP}
  # Home (eventually) use either _CG28 or _HOME_CHECK
  _CG28
  M190 S{BED_TEMP}
  BED_MESH_CLEAR
  BED_MESH_CALIBRATE
  TURN_OFF_HEATERS
  SAVE_CONFIG

[gcode_macro CHECK_FILAMENT]
gcode:
  {% if printer['filament_switch_sensor filament_sensor'].filament_detected != True %}
    {action_raise_error("No filament present, aborting print")}
  {% endif %}

[gcode_macro PREHEAT_BED]
description: Pre-heats bed
gcode:
  SET_HEATER_TEMPERATURE HEATER=heater_bed TARGET=50
  _CG28
  G1 Z10 F3000

[gcode_macro COOL_ALL]
description: Cooldown all heaters
gcode:
  TURN_OFF_HEATERS

[gcode_macro BED_TRAMMING_WARM]
description: Assisted bed tramming with warm bed
gcode:
  {% set BED_TEMP = params.BED_TEMP|default(60)|float %}
  M140 S{BED_TEMP}	
  _CG28
  M190 S{BED_TEMP}
  SCREWS_TILT_CALCULATE

[gcode_macro BED_TRAMMING_COLD]
description: Assisted bed tramming with cold bed
gcode:
  _CG28
  SCREWS_TILT_CALCULATE

[gcode_macro CENTER_NOZZLE_ON_BED]
description: Move the nozzle to center of bed (Bed: 220x220)
gcode:
  _CG28
  G1 X110 Y110 Z10 F6000

# Replace M109 (wait for hotend temperature) and M190 (wait for bed temperature) with TEMPERATURE_WAIT.
# This just makes Klipper resume immediately after reaching temp. Otherwise, it waits for the temperature to stabilize.
[gcode_macro M109]
rename_existing: M99109
gcode:
    #Parameters
    {% set s = params.S|float %}
    
    M104 {% for p in params %}{'%s%s' % (p, params[p])}{% endfor %}  ; Set hotend temp
    {% if s != 0 %}
        TEMPERATURE_WAIT SENSOR=extruder MINIMUM={s} MAXIMUM={s+1}   ; Wait for hotend temp (within 1 degree)
    {% endif %}

[gcode_macro M190]
rename_existing: M99190
gcode:
    #Parameters
    {% set s = params.S|float %}

    M140 {% for p in params %}{'%s%s' % (p, params[p])}{% endfor %}   ; Set bed temp
    {% if s != 0 %}
        TEMPERATURE_WAIT SENSOR=heater_bed MINIMUM={s} MAXIMUM={s+1}  ; Wait for bed temp (within 1 degree)
    {% endif %}

# Park toolhead
[gcode_macro M125]
gcode:
    SAVE_GCODE_STATE NAME=parking
    M117 Parking toolhead
    G91
    G1 Z10 F600 # move up 10 mm
    G90
    G1 X150 Y10 F4000 # move to park position
    RESTORE_GCODE_STATE NAME=parking

# load filament
[gcode_macro M701]
gcode:
    LOAD_FILAMENT

# unload filament
[gcode_macro M702]
gcode:
    UNLOAD_FILAMENT

# SDCard 'looping' (aka Marlin M808 commands) support
#
# Support SDCard looping
[sdcard_loop]

# 'Marlin' style M808 compatibility macro for SDCard looping
[gcode_macro M808]
gcode:
    {% if params.K is not defined and params.L is defined %}SDCARD_LOOP_BEGIN COUNT={params.L|int}{% endif %}
    {% if params.K is not defined and params.L is not defined %}SDCARD_LOOP_END{% endif %}
    {% if params.K is defined and params.L is not defined %}SDCARD_LOOP_DESIST{% endif %}



################################### INPUT SHAPER #####################################
# Manually via ssh to obtain the images (PNG) of the resonances for each axe (X/Y).
# Example for the Creality Sonic Pad (OS=OpenWRT, use /usr/share as 'home' and 'root' as user !!!)
# Axe X:
# /usr/share/klipper/scripts/calibrate_shaper.py /tmp/calibration_data_x_*.csv -o /mnt/UDISK/printer_config/shaper_calibrate_x.png
# Axe Y:
# /usr/share/klipper/scripts/calibrate_shaper.py /tmp/calibration_data_y_*.csv -o /mnt/UDISK/printer_config/shaper_calibrate_y.png
#
# If root on the Sonic Pad, test with 'shell_command', the shell is 'ash' from busybox so use with caution.
# Read more about measuring resonances, smoothing, offline processing of shaper data etc.
# https://www.klipper3d.org/Measuring_Resonances.html
#
# Input shaper auto-calibration (run tests then generate csv output)
# Don't forget SAVE_CONFIG to save and restart Klipper
# The value 'max_accel' won't be automatically modified, you have to do it in the [printer] section, according to the results
# of the auto-calibration.
# With 'bed-slinger' use the lowest max_accel of X/Y axis.
#
[gcode_macro ADXL_TEST]
description: ADXL Test
gcode:
  ACCELEROMETER_QUERY

[gcode_macro ADXL_NOISE]
description: Measure Accelerometer Noise
gcode:
  MEASURE_AXES_NOISE

[gcode_macro HOTEND_INPUT_SHAPER]
description: test resonances in x direction for the hotend
gcode:
  M118 DO NOT TOUCH THE PRINTER UNTIL DONE!!!
  _HOME_CHECK
  SHAPER_CALIBRATE AXIS=X
  RUN_SHELL_COMMAND CMD=adxl_x
  M118 Test done
  SAVE_CONFIG
  
[gcode_macro BED_INPUT_SHAPER]
description: test resonances in y direction for the heated bed
gcode:
  M118 DO NOT TOUCH THE PRINTER UNTIL DONE!!!
  _HOME_CHECK
  SHAPER_CALIBRATE AXIS=Y
  RUN_SHELL_COMMAND CMD=adxl_y
  M118 Test done
  SAVE_CONFIG

[gcode_macro ADXL_SHAPE_ALL]
description: Test resonances for both axis
gcode:
    M118 DO NOT TOUCH THE PRINTER UNTIL DONE!!!
    LAZY_HOME
    SHAPER_CALIBRATE
    RUN_SHELL_COMMAND CMD=adxl_x
    RUN_SHELL_COMMAND CMD=adxl_y
    M118 Test done
    SAVE_CONFIG

[gcode_macro BKUP_CSV]
description: Backup csv files registered in /tmp directory emptied on poweroff
gcode:
    M118 Backup all csv files !
    RUN_SHELL_COMMAND CMD=bkup_csv
    M118 Backup done

#=====================================================
# Power Operations / HA Plug
#=====================================================
[gcode_macro POWER_ON_PRINTER]
gcode:
  {action_call_remote_method("set_device_power",
                             device="Ender3S1",
                             state="on")}
  
[gcode_macro POWER_OFF_PRINTER]
gcode:
  {action_call_remote_method("set_device_power",
                             device="Ender3S1",
                             state="off")}
  
[delayed_gcode delayed_printer_off]
initial_duration: 0.
gcode:
#  {% if printer.idle_timeout.state == "Idle" %}
#  {% if printer.idle_timeout.state == "Idle" or printer.idle_timeout.state == "Ready" %}
  {% if printer.idle_timeout.state != "Printing" %}
    POWER_OFF_PRINTER
  {% endif %}
  
[idle_timeout]
gcode:
  M84 ; disable steppers
  TURN_OFF_HEATERS
  UPDATE_DELAYED_GCODE ID=delayed_printer_off DURATION=600
  
#======================================================
# SET_PRINT_STATS_INFO with Cura
#======================================================
# Klipper provides the SET_PRINT_STATS_INFO macro so that slicers can set the Layer Count and
# Current Layer information, but Cura doesn't have a way to use this directly (the only "g-code
# on layer change" post-processing plugin doesn't support variables), so the only way to work 
# around is by adding a replacement post-processing script and a specific macro to Klipper.
#
# To add the script to Cura, use the following steps:
# - Open Cura
# - Open the "Extensions" menu, then "Post processing", and click on "Modify G-Code"
# - Click the "Add Script" button, and select "Search and Replace" from the options
# - On the "Search" textbox, enter this: ;(LAYER|LAYER_COUNT)\:(\d+)
# - On the "Replace" textbox, enter this: ;\1:\2\n_CURA_SET_PRINT_STATS_INFO \1=\2
# - Tick the "Use Regular Expressions" checkbox
#- Click Close
#
#[print_stats]
# Pass slicer info (layer count, layer current) to Klipper

[gcode_macro _CURA_SET_PRINT_STATS_INFO]
gcode:
  {% if params.LAYER_COUNT is defined %}
    SET_PRINT_STATS_INFO TOTAL_LAYER={params.LAYER_COUNT}
  {% endif %}
  {% if params.LAYER is defined %}
    SET_PRINT_STATS_INFO CURRENT_LAYER={(params.LAYER | int) + 1}
  {% endif %}
```

 </details>
 
Les fichiers sont disponibles dans le dossier… Fichiers (clic droit pour enregistrer :smirk: ) :
-  le [printer.cfg](https://github.com/fran6p/SonicPad/raw/main/Fichiers/printer.cfg),
-  les [macros](https://github.com/fran6p/SonicPad/raw/main/Fichiers/macros.cfg) .

…

à continuer …
 
