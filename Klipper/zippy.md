### Testées

1. [Affichage des coordonnées min/max/actuel de la sonde](./MyConfiguration/macros/zippy/get_probe_limits.cfg)

<details>

```
# Macro to calculate the probe min/max/current coordinates

##########################DEPENDENCIES##########################
# 
# This config section is required to output text to the console
# which is used by the macro. If you already have an equivalent
# config section elsewhere, you can comment this one out.
#[respond]
# 
################################################################

[gcode_macro GET_PROBE_LIMITS]
description: Calculates the probe min/max/current coordinates
gcode: 
    {% set config = printer.configfile.settings %}
    # Find probe config in configfile
    {% if config["bltouch"] %}
        # bltouch section found
        {% set probe = config["bltouch"] %}
        {% set has_probe = True %}
    {% elif config["probe"] %}
        # probe section found
        {% set probe = config["probe"] %}
        {% set has_probe = True %}
    {% elif config["beacon"] %}
        # probe section found
        {% set probe = config["beacon"] %}
        {% set has_probe = True %}
    {% else %}
        # No probe or bltouch sections found
        RESPOND MSG="Failed to detect probe in configfile"
    {% endif %}
    {% if has_probe %}
        {% set stepperx = config["stepper_x"] %}
        {% set steppery = config["stepper_y"] %}
        {% set xprobemin = stepperx["position_min"]|float + probe["x_offset"]|float %} 
        {% set xprobemax = stepperx["position_max"]|float + probe["x_offset"]|float %} 
        {% set yprobemin = steppery["position_min"]|float + probe["y_offset"]|float %} 
        {% set yprobemax = steppery["position_max"]|float + probe["y_offset"]|float %}
        RESPOND MSG="Configured Probe X-Offset {probe.x_offset}"
        RESPOND MSG="Configured Probe Y-Offset {probe.y_offset}"
        {% if probe.z_offset is defined %}
            RESPOND MSG="Configured Probe Z-Offset {probe.z_offset}"
        {% elif probe.trigger_distance is defined %}
            RESPOND MSG="Configured Probe Trigger Distance {probe.trigger_distance}"
        {% endif %}
        RESPOND MSG="Minimum PROBE position X={xprobemin} Y={yprobemin}" 
        RESPOND MSG="Maximum PROBE position X={xprobemax} Y={yprobemax}"
        # check if printer homed
        {% if "xyz" in printer.toolhead.homed_axes %} 
            {% set curprobex = printer.toolhead.position.x|float + probe["x_offset"]|float %} 
            {% set curprobey = printer.toolhead.position.y|float + probe["y_offset"]|float %} 
            RESPOND MSG="Current PROBE position X={curprobex} Y={curprobey}"
        {% endif %}
    {% endif %}
```

</details>

2. [Test de vitesses](./MyConfiguration/macros/zippy/test_speed.cfg)

<details>

```
# Home, get position, throw around toolhead, home again.
# If MCU stepper positions (first line in GET_POSITION) are greater than a full step different (your number of microsteps), then skipping occured.
# We only measure to a full step to accomodate for endstop variance.
# Example: TEST_SPEED SPEED=300 ACCEL=5000 ITERATIONS=10

[gcode_macro TEST_SPEED]
gcode:
	# Speed
	{% set speed  = params.SPEED|default(printer.configfile.settings.printer.max_velocity)|int %}
	# Iterations
	{% set iterations = params.ITERATIONS|default(5)|int %}
	# Acceleration
	{% set accel  = params.ACCEL|default(printer.configfile.settings.printer.max_accel)|int %}
	# Bounding inset for large pattern (helps prevent slamming the toolhead into the sides after small skips, and helps to account for machines with imperfectly set dimensions)
	{% set bound = params.BOUND|default(20)|int %}
	# Size for small pattern box
	{% set smallpatternsize = SMALLPATTERNSIZE|default(20)|int %}
	
	# Large pattern
		# Max positions, inset by BOUND
		{% set x_min = printer.toolhead.axis_minimum.x + bound %}
		{% set x_max = printer.toolhead.axis_maximum.x - bound %}
		{% set y_min = printer.toolhead.axis_minimum.y + bound %}
		{% set y_max = printer.toolhead.axis_maximum.y - bound %}
	
	# Small pattern at center
		# Find X/Y center point
		{% set x_center = (printer.toolhead.axis_minimum.x|float + printer.toolhead.axis_maximum.x|float ) / 2 %}
		{% set y_center = (printer.toolhead.axis_minimum.y|float + printer.toolhead.axis_maximum.y|float ) / 2 %}
		
		# Set small pattern box around center point
		{% set x_center_min = x_center - (smallpatternsize/2) %}
		{% set x_center_max = x_center + (smallpatternsize/2) %}
		{% set y_center_min = y_center - (smallpatternsize/2) %}
		{% set y_center_max = y_center + (smallpatternsize/2) %}

	# Save current gcode state (absolute/relative, etc)
	SAVE_GCODE_STATE NAME=TEST_SPEED
	
	# Output parameters to g-code terminal
	{ action_respond_info("TEST_SPEED: starting %d iterations at speed %d, accel %d" % (iterations, speed, accel)) }
	
	# Home and get position for comparison later:
		G28
		# QGL if not already QGLd (only if QGL section exists in config)
		{% if printer.configfile.settings.quad_gantry_level %}
			{% if printer.quad_gantry_level.applied == False %}
				QUAD_GANTRY_LEVEL
				G28 Z
			{% endif %}
		{% endif %}	
		G90
		G0 X{printer.toolhead.axis_maximum.x-1} Y{printer.toolhead.axis_maximum.y-1} F{30*60}
		G4 P1000 
		GET_POSITION

	# Go to starting position
	G0 X{x_min} Y{y_min} Z{bound + 10} F{speed*60}

	# Set new limits
	SET_VELOCITY_LIMIT VELOCITY={speed} ACCEL={accel} ACCEL_TO_DECEL={accel / 2}

	{% for i in range(iterations) %}
		# Large pattern
			# Diagonals
			G0 X{x_min} Y{y_min} F{speed*60}
			G0 X{x_max} Y{y_max} F{speed*60}
			G0 X{x_min} Y{y_min} F{speed*60}
			G0 X{x_max} Y{y_min} F{speed*60}
			G0 X{x_min} Y{y_max} F{speed*60}
			G0 X{x_max} Y{y_min} F{speed*60}
			
			# Box
			G0 X{x_min} Y{y_min} F{speed*60}
			G0 X{x_min} Y{y_max} F{speed*60}
			G0 X{x_max} Y{y_max} F{speed*60}
			G0 X{x_max} Y{y_min} F{speed*60}
		
		# Small pattern
			# Small diagonals 
			G0 X{x_center_min} Y{y_center_min} F{speed*60}
			G0 X{x_center_max} Y{y_center_max} F{speed*60}
			G0 X{x_center_min} Y{y_center_min} F{speed*60}
			G0 X{x_center_max} Y{y_center_min} F{speed*60}
			G0 X{x_center_min} Y{y_center_max} F{speed*60}
			G0 X{x_center_max} Y{y_center_min} F{speed*60}
			
			# Small box
			G0 X{x_center_min} Y{y_center_min} F{speed*60}
			G0 X{x_center_min} Y{y_center_max} F{speed*60}
			G0 X{x_center_max} Y{y_center_max} F{speed*60}
			G0 X{x_center_max} Y{y_center_min} F{speed*60}
	{% endfor %}

	# Restore max speed/accel/accel_to_decel to their configured values
	SET_VELOCITY_LIMIT VELOCITY={printer.configfile.settings.printer.max_velocity} ACCEL={printer.configfile.settings.printer.max_accel} ACCEL_TO_DECEL={printer.configfile.settings.printer.max_accel_to_decel} 

	# Re-home and get position again for comparison:
		G28
		# Go to XY home positions (in case your homing override leaves it elsewhere)
		G90
		G0 X{printer.toolhead.axis_maximum.x-1} Y{printer.toolhead.axis_maximum.y-1} F{30*60}
		G4 P1000 
		GET_POSITION

	# Restore previous gcode state (absolute/relative, etc)
	RESTORE_GCODE_STATE NAME=TEST_SPEED
```

</details>

3. [Statistiques](./MyConfiguration/macros/zippy/zippystats.cfg)

<details>

```
[gcode_macro GET_POSITION_STATS]
gcode:
    {% set FIL_SWITCH = 'filament_switch_sensor filament_sensor' %}
    {% set FIL_MOTION = 'filament_motion_sensor filament_motion' %}
    {% set CHAMBER_HEAT = 'temperature_fan chamber' %}
    {% set config = printer.configfile.config %}
    {% if printer.toolhead.homed_axes %}
        RESPOND MSG="Homed Axis: "{printer.toolhead.homed_axes}
    {% else %}
        RESPOND MSG="Homed Axis: none"
    {% endif %}
    {% if "xyz" in printer.toolhead.homed_axes %}
        GET_POSITION
        RESPOND MSG="Toolhead Position: X{printer.toolhead.position.x}, Y{printer.toolhead.position.y}, Z{printer.toolhead.position.z}"
        RESPOND MSG="Gcode Position: X{printer.gcode_move.gcode_position.x}, Y{printer.gcode_move.gcode_position.y}, Z{printer.gcode_move.gcode_position.z}, E{printer.gcode_move.gcode_position.e}"
        RESPOND MSG="Stalls: "{printer.toolhead.stalls}
        RESPOND MSG="Minimum Position: X{printer.toolhead.axis_minimum.x}, Y{printer.toolhead.axis_minimum.y}, Z{printer.toolhead.axis_minimum.z}"
        RESPOND MSG="Maximum Position: X{printer.toolhead.axis_maximum.x}, Y{printer.toolhead.axis_maximum.y}, Z{printer.toolhead.axis_maximum.z}"
        RESPOND MSG="Maximum Velocity: {printer.toolhead.max_velocity}mm/s"
        RESPOND MSG="Maximum Acceleration: {printer.toolhead.max_accel}mm/s/s"
        RESPOND MSG="Maximum Accel-to-Decel: {printer.toolhead.max_accel_to_decel}mm/s/s"
        RESPOND MSG="Square Corner Velocity: {printer.toolhead.square_corner_velocity}mm/s"
        RESPOND MSG="Live Velocity: {printer.motion_report.live_velocity}mm/s"
        RESPOND MSG="Gcode Speed: {printer.gcode_move.speed}mm/s"
        RESPOND MSG="Gcode Speed Factor: {(printer.gcode_move.speed_factor * 100)}%"
        RESPOND MSG="Gcode Extrude Factor: {(printer.gcode_move.extrude_factor * 100)}%"
        RESPOND MSG="Absolute Positioning: "{printer.gcode_move.absolute_coordinates}
        RESPOND MSG="Absolute Extrusion: "{printer.gcode_move.absolute_extrude}
        GET_PROBE_LIMITS
        {% if printer.quad_gantry_level %}
            RESPOND MSG="Quad gantry Level Applied: "{printer.quad_gantry_level.applied}
        {% endif %}
        {% if printer.z_tilt %}
            RESPOND MSG="Z-Tilt Applied: "{printer.z_tilt.applied}
        {% endif %}
        {% if printer.bed_mesh %}
            {% set bed_mesh = printer.bed_mesh %}
            RESPOND MSG="Bed Mesh Profile: "{bed_mesh.profile_name}
            RESPOND MSG="Bed Mesh Min: {bed_mesh.mesh_min}"
            RESPOND MSG="Bed Mesh Max: {bed_mesh.mesh_max}"
        {% endif %}
        {% if printer[FIL_SWITCH] %}
            {% set fil_sensor = printer[FIL_SWITCH] %}
            RESPOND MSG="Filament Sensor Enabled: "{fil_sensor.enabled}
            RESPOND MSG="Filament Detected: "{fil_sensor.filament_detected}
        {% endif %}
        {% if printer[FIL_MOTION] %}
            {% set fil_sensor = printer[FIL_MOTION] %}
            RESPOND MSG="Filament Sensor Enabled: "{fil_sensor.enabled}
            RESPOND MSG="Filament Detected: "{fil_sensor.filament_detected}
        {% endif %}
        {% set extruder = printer['extruder'] %}
        {% set heater_bed = printer['heater_bed'] %}
        {% set chamber = printer[CHAMBER_HEAT] %}
        RESPOND MSG="Extruder Temperature: {extruder.temperature}C"
        RESPOND MSG="Extruder Target Temp: {extruder.target}C"
        RESPOND MSG="Extruder Power: {(extruder.power * 100)}%"
        RESPOND MSG="Extruder Can Extrude: {extruder.can_extrude}"
        RESPOND MSG="Bed Temperature: {heater_bed.temperature}C"
        RESPOND MSG="Bed Target Temp: {heater_bed.target}C"
        RESPOND MSG="Bed Power: {(heater_bed.power * 100)}%"
        {% if chamber %}
            RESPOND MSG="Chamber Temperature: {chamber.temperature}C"
            RESPOND MSG="Chamber Target Temp: {chamber.target}C"
            {% if chamber.speed %}
                RESPOND MSG="Chamber Fan: {(chamber.speed * 100)}%"
            {% elif chamber.power %}
                RESPOND MSG="Bed Power: {(heater_bed.power * 100)}%"
            {% endif %}
        {% endif %}
        #TODO Support different combinations. Currently assumes all drivers are the same.
        {% if config["tmc2130 stepper_x"] %}
            {% set driver_x = printer["tmc2130 stepper_x"] %}
            {% set driver_y = printer["tmc2130 stepper_y"] %}
            {% set driver_z = printer["tmc2130 stepper_z"] %}
            {% if config["tmc2130 stepper_z1"] %}
                {% set driver_z1 = printer["tmc2130 stepper_z1"] %}
            {% else %}
                {% set driver_z1 = 0 %}
            {% endif %}
            {% set driver_e = printer["tmc2130 extruder"] %}
        {% elif config["tmc2208 stepper_x"] %}
            {% set driver_x = printer["tmc2208 stepper_x"] %}
            {% set driver_y = printer["tmc2208 stepper_y"] %}
            {% set driver_z = printer["tmc2208 stepper_z"] %}
            {% if config["tmc2208 stepper_z1"] %}
                {% set driver_z1 = printer["tmc2208 stepper_z1"] %}
            {% else %}
                {% set driver_z1 = 0 %}
            {% endif %}
            {% set driver_e = printer["tmc2208 extruder"] %}
        {% elif config["tmc2209 stepper_x"] %}
            {% set driver_x = printer["tmc2209 stepper_x"] %}
            {% set driver_y = printer["tmc2209 stepper_y"] %}
            {% set driver_z = printer["tmc2209 stepper_z"] %}
            {% if config["tmc2209 stepper_z1"] %}
                {% set driver_z1 = printer["tmc2209 stepper_z1"] %}
            {% else %}
                {% set driver_z1 = 0 %}
            {% endif %}
            {% set driver_e = printer["tmc2209 extruder"] %}
        {% elif config["tmc2660 stepper_x"] %}
            {% set driver_x = printer["tmc2660 stepper_x"] %}
            {% set driver_y = printer["tmc2660 stepper_y"] %}
            {% set driver_z = printer["tmc2660 stepper_z"] %}
            {% if config["tmc2660 stepper_z1"] %}
                {% set driver_z1 = printer["tmc2660 stepper_z1"] %}
            {% else %}
                {% set driver_z1 = 0 %}
            {% endif %}
            {% set driver_e = printer["tmc2660 extruder"] %}
        {% elif config["tmc5160 stepper_x"] %}
            {% set driver_x = printer["tmc5160 stepper_x"] %}
            {% set driver_y = printer["tmc5160 stepper_y"] %}
            {% set driver_z = printer["tmc5160 stepper_z"] %}
            {% if config["tmc5160 stepper_z1"] %}
                {% set driver_z1 = printer["tmc5160 stepper_z1"] %}
            {% else %}
                {% set driver_z1 = 0 %}
            {% endif %}
            {% set driver_e = printer["tmc5160 extruder"] %}
        {% else %}
            {% set driver = 0 %}
        {% endif %}
        {% if driver != 0 %}
            RESPOND MSG="X Stepper Run Current: "{driver_x.run_current}
            {% if driver_x.hold_current %}
                RESPOND MSG="X Stepper Hold Current: "{driver_x.hold_current}
            {% endif %}
            RESPOND MSG="Y Stepper Run Current: "{driver_y.run_current}
            {% if driver_y.hold_current %}
                RESPOND MSG="Y Stepper Hold Current: "{driver_y.hold_current}
            {% endif %}
            {% if driver_z1 == 0 %}
                RESPOND MSG="Z Stepper Run Current: "{driver_z.run_current}
                {% if driver_z.hold_current %}
                    RESPOND MSG="Z Stepper Hold Current: "{driver_z.hold_current}
                {% endif %}
            {% else %}
                RESPOND MSG="Z0 Stepper Run Current: "{driver_z.run_current}
                {% if driver_z.hold_current %}
                    RESPOND MSG="Z0 Stepper Hold Current: "{driver_z.hold_current}
                {% endif %}
                RESPOND MSG="Z1 Stepper Run Current: "{driver_z1.run_current}
                {% if driver_z1.hold_current %}
                    RESPOND MSG="Z1 Stepper Hold Current: "{driver_z1.hold_current}
                {% endif %}
            {% endif %}
            RESPOND MSG="Extruder Run Current: "{driver_e.run_current}
            {% if driver_e.hold_current %}
                RESPOND MSG="Extruder Hold Current: "{driver_e.hold_current}
            {% endif %}
        {% endif %}

    {% else %}
        RESPOND TYPE=error MSG="All axis must be homed to retrieve position stats."
    {% endif %}

[gcode_macro GET_SYS_INFO]
gcode:
    RESPOND MSG="Load: "{printer.system_stats.sysload}
    RESPOND MSG="CPU: "{printer.system_stats.cputime}"%"
    RESPOND MSG="Free Mem: "{printer.system_stats.memavail}" B"

[gcode_macro GET_PRINT_STATS]
gcode:
    RESPOND MSG="File: "{printer.print_stats.filename}
    RESPOND MSG="File Path: "{printer.virtual_sdcard.file_path}
    RESPOND MSG="File Position: "{printer.virtual_sdcard.file_position}
    RESPOND MSG="File Size: "{printer.virtual_sdcard.file_size}
    RESPOND MSG="Total Duration: "{printer.print_stats.total_duration}
    RESPOND MSG="Print Duration: "{printer.print_stats.print_duration}
    RESPOND MSG="Filament Used: "{printer.print_stats.filament_used}
    RESPOND MSG="State: "{printer.print_stats.state}
    RESPOND MSG="State: "{printer.print_stats.message}
    RESPOND MSG="Total Layers: "{printer.print_stats.info.total_layer}
    RESPOND MSG="Current Layer: "{printer.print_stats.info.current_layer}
    RESPOND MSG="Paused: "{printer.pause_resume.is_paused}
    RESPOND MSG="Idle State: "{printer.idle_timeout.state}
    RESPOND MSG="Printing Time: "{printer.idle_timeout.printing_time}
    RESPOND MSG="Print Active: "{printer.virtual_sdcard.is_active}
    RESPOND MSG="Print Progress: "{printer.virtual_sdcard.progress}
```

</details>


4. [Nivellement plateau](./MyConfiguration/macros/zippy/bed_leveling.cfg)

Par rapport au fichier originel, il faut modifier dans la macro `BED_LEVELING` le nom du `SENSOR` dans les lignes débutant par `SET_FILAMENT_SENSOR`, Qidi utilise `fila` comme nom de senseur. Extrait du `printer.cfg`:

```
#################################################
#           Filament sensor settings            #
#################################################

[filament_switch_sensor fila]
pause_on_runout: True
runout_gcode:
            PAUSE
            SET_FILAMENT_SENSOR SENSOR=fila ENABLE=1
event_delay: 3.0
pause_delay: 0.5
switch_pin: !PC1
```

Ci-dessous les lignes originelles sont commentées `# SET_FILAMENT_SENSOR …` 

<details>

```
################################
######### MESH_CHECK ###########
################################
[gcode_macro MESH_CHECK]
description: Checks if a mesh exists to determine whether to create a new one
gcode:
    {% if printer.bed_mesh.profiles['default'] is defined %}
        BED_MESH_PROFILE LOAD='default' ; load mesh
    {% else %}
        BED_MESH_CALIBRATE ; generate new mesh
    {% endif %}

[gcode_macro _TEST_MESH]
gcode:
    {% set bed_mesh = printer.bed_mesh %}
    RESPOND MSG="Bed Mesh Profile: "{bed_mesh.profile_name}
    RESPOND MSG="Bed Mesh Min: {bed_mesh.mesh_min}"
    RESPOND MSG="Bed Mesh Max: {bed_mesh.mesh_max}"
    RESPOND MSG="Probe Matrix: {bed_mesh.probed_matrix}"
    RESPOND MSG="Mesh Matrix: {bed_mesh.mesh_matrix}"

[gcode_macro BED_LEVELING]
description: Start Bed Leveling
gcode:
  {% if 'PROBE_COUNT' in params|upper %}
    {% set get_count = ('PROBE_COUNT=' + params.PROBE_COUNT) %}
  {%else %}
    {% set get_count = "" %}
  {% endif %}
  {% set bed_temp = params.BED_TEMP|default(50)|float %}
  {% set hotend_temp = params.HOTEND_TEMP|default(140)|float %}
  {% set nozzle_clear_temp = params.NOZZLE_CLEAR_TEMP|default(240)|float %}
#  SET_FILAMENT_SENSOR SENSOR=fila_sensor ENABLE=0
  SET_FILAMENT_SENSOR SENSOR=fila ENABLE=0 # QIDI
  {% if printer.toolhead.homed_axes != "xyz" %}
    G28
  {% endif %}
  BED_MESH_CLEAR
  SET_VELOCITY_LIMIT ACCEL_TO_DECEL=5000
  BED_MESH_CALIBRATE {get_count}
  BED_MESH_OUTPUT
  {% set y_park = printer.toolhead.axis_maximum.y/2 %}
  {% set x_park = printer.toolhead.axis_maximum.x|float - 10.0 %}
  G1 X{x_park} Y{y_park} F10000
  TURN_OFF_HEATERS
#  SET_FILAMENT_SENSOR SENSOR=filam ENABLE=1
  SET_FILAMENT_SENSOR SENSOR=fila ENABLE=1 # QIDI
  M84
```

</details>

5. [Compensation de résonances](./MyConfiguration/macros/zippy/shaping.cfg)

Ces macros utilisant le Gcode étendu `RUN_SHELL_COMMAND`, il est donc nécessaire pour que tout fonctionne :

- [ce script Python](../Upgrades/gcode_shell_command.md) doit être installé
- les scripts shell doivent avoir été créés [voir ici](./MyConfiguration/scripts/)
- inclure le fichier [shell_command.cfg](./MyConfiguration/macros/shell_command.cfg) dans le `printer.cfg`

<details>


```
################################### INPUT SHAPER #####################################
# Manually via ssh to obtain the images (PNG) of the resonances for each axe (X/Y).
# ~/klipper/scripts/calibrate_shaper.py /tmp/calibration_data_x_*.csv -o ~/klipper_config/adxl_results/shaper_calibrate_x.png
#
# ~/klipper/scripts/calibrate_shaper.py /tmp/calibration_data_y_*.csv -o ~/klipper_config/adxl_results/shaper_calibrate_y.png
#
# Read more about measuring resonances, smoothing, offline processing of shaper data etc.
# https://www.klipper3d.org/Measuring_Resonances.html
#
# Input shaper auto-calibration (run tests then generate csv output)
# Don't forget SAVE_CONFIG to save and restart Klipper
# The value 'max_accel' won't be automatically modified, you have to do it in the
# [printer] section, according to the results of the auto-calibration.
# With 'bed-slinger' use the lowest max_accel of X/Y axis.
#

# Shaping
[gcode_macro ADXL_TEST]
description: ADXL Test
gcode:
    ACCELEROMETER_QUERY

[gcode_macro ADXL_NOISE]
description: Measure Accelerometer Noise
gcode:
    MEASURE_AXES_NOISE

[gcode_macro ADXL_SHAPE_X]
description: test resonances in x direction for the hotend
gcode:
    M118 DO NOT TOUCH THE PRINTER UNTIL DONE!!!
    G28
    SHAPER_CALIBRATE AXIS=X
    RUN_SHELL_COMMAND CMD=adxl_x
    M118 Test done
    SAVE_CONFIG
  
[gcode_macro ADXL_SHAPE_Y]
description: test resonances in y direction for the heated bed
gcode:
    M118 DO NOT TOUCH THE PRINTER UNTIL DONE!!!
    G28
    SHAPER_CALIBRATE AXIS=Y
    RUN_SHELL_COMMAND CMD=adxl_y
    M118 Test done
    SAVE_CONFIG

[gcode_macro ADXL_SHAPE_ALL]
description: Test resonances for both axis
gcode:
    M118 DO NOT TOUCH THE PRINTER UNTIL DONE!!!
    G28
    SHAPER_CALIBRATE
    RUN_SHELL_COMMAND CMD=adxl_x
    RUN_SHELL_COMMAND CMD=adxl_y
    M118 Test done
    SAVE_CONFIG
```

</details>


6. [M600 alternatif](./MyConfiguration/macros/zippy/smart-m600.cfg)

***IMPORTANT:***

**Ajuster les variables de la macro `_m600cfg` en fonction de l'imprimante**

<details>

```
#####################################
#   Smart Filament Change Macros    #
#      Version 2.5.5 2023-5-6       #
#####################################
#####     PLEASE READ BELOW     #####
#####################################
# This macro requires configuration!
# 
# More information available here:
# https://github.com/rootiest/zippy-klipper_config/blob/master/extras/filament_change/README.md
# 
# You must adjust the variables
# under M600 CONFIGURATION to fit
# the specifications of your machine.

################################
###### M600 CONFIGURATION ######
################################
[gcode_macro _m600cfg]
# The following variables define the behavior of macros in this file:
variable_sensor_name: 'fila'            # The name of the filament sensor used # X-Max3 = fila
                                        # The following manage behavior during filament changes:
variable_default_temp: 220              # The default temperature used
variable_x: 150                         # Filament change park coordinate for X
variable_y: 15                          # Filament change park coordinate for Y
variable_zmin: 100                      # Minimum filament change park height
variable_z: 10                          # Filament change z-hop height
variable_load_delay: 0                  # Delay before loading on filament insert
variable_load_fast: 70                  # Length to load the filament before reaching the hotend
variable_load_slow: 20                  # Length to extrude/purge filament out of hotend
variable_unload_length: 80              # Length of filament to retract during unload
variable_purge_length: 50               # Length of filament to extrude during purge
variable_post_load_retraction: 1        # Amount to retract after loading to limit oozing (in mm)
                                        # NOTE: Speeds are given in mm/min 
variable_fast_speed: 1000               # Speed for fast extruder moves (between extruder and hotend)
variable_med_speed: 500                 # Speed for medium extruder moves (extruder catching the new filament)
variable_slow_speed: 250                # Speed for slow extruder moves (actual extrusion out of the hotend)
variable_park_speed: 9000               # Speed of X/Y moves during parking
                                        # See the documentation linked above for details about the below settings
variable_output: 118                    # Select 116, 117, or 118 to specify output method for feedback
variable_led_status: False              # Use LED Status macros such as on the stealthburner
variable_audio_status: False            # Use audio feedback macros
variable_audio_freq: 5                  # The frequency to repeat the audio tone
variable_audio_macro: 'CHANGE_TUNE'     # The frequency to repeat the audio tone
variable_use_telegram: False            # Use Telegram feedback macros
variable_use_fluidd: True               # Output subsequent macro commands to console
                                        # The following manages the optional automated sensor toggling:
variable_auto_sensor: True              # Automate filament sensor toggling
variable_auto_load: False
variable_auto_unload: False

# Do Not Change Below
variable_coldstart: False
variable_runout: False
variable_prev_temp: 0
gcode: # No gcode needed

################################
####### CHANGE_FILAMENT ########
################################
[gcode_macro CHANGE_FILAMENT]
description: Change the filament in toolhead
gcode:
    {% set m600cfg = printer["gcode_macro _m600cfg"] %}
    CG28
    SET_GCODE_VARIABLE MACRO=_m600cfg VARIABLE=coldstart VALUE=True
    M{m600cfg.output|int} Filament Change
    M600
    UNLOAD_FILAMENT
    {% if m600cfg.auto_sensor == True %}
        ENABLEFILAMENTSENSOR
    {% endif %}

################################
######### COLOR_CHANGE #########
################################
[gcode_macro COLOR_CHANGE]
description: Procedure when Color Change is triggered
gcode:
    {% set m600cfg = printer["gcode_macro _m600cfg"] %} ; get m600cfg variables
    M{m600cfg.output|int} Filament Runout
    {% if m600cfg.use_telegram == True %}
        TELEGRAM_FILAMENT_RUNOUT
    {% endif %}
    SET_IDLE_TIMEOUT TIMEOUT={m600cfg.m600_idle_time}
    {% if m600cfg.audio_status == True %} ; if using audio status alerts
        {m600cfg.audio_macro}
        ALERT_BEEP_ON
    {% endif %}
    M600
    SET_GCODE_VARIABLE MACRO=_m600cfg VARIABLE=prev_temp VALUE={printer.extruder.target}
    SET_GCODE_VARIABLE MACRO=_m600cfg VARIABLE=runout VALUE=True
    M{m600cfg.output|int} Unloading Filament...
    UNLOAD_FILAMENT 

################################
####### FILAMENT_RUNOUT ########
################################
[gcode_macro FILAMENT_RUNOUT]
description: Procedure when Filament Runout Sensor is triggered
gcode:
    {% set m600cfg = printer["gcode_macro _m600cfg"] %}
    {% if m600cfg.coldstart == False %}
        M{m600cfg.output|int} Filament Runout
        {% if m600cfg.use_telegram == True %}
            TELEGRAM_FILAMENT_RUNOUT
        {% endif %}
        SET_IDLE_TIMEOUT TIMEOUT=3600
        {% if m600cfg.audio_status == True %}
            CHANGE_TUNE
            ALERT_BEEP_ON
        {% endif %}
        M600
        {% if m600cfg.auto_unload == True %}
            M{m600cfg.output|int} Unloading Filament
            UNLOAD_FILAMENT
        {% else %}
            {% if m600cfg.use_fluidd == True %}
                M118 Run UNLOAD_FILAMENT to unload.
                {% if m600cfg.audio_status == True and m600cfg.audio_frequency > 0 %}
                    M118 Run ALERT_BEEP_OFF to silence beeper
                {% endif %}
            {% endif %}
        {% endif %}
        SET_GCODE_VARIABLE MACRO=_m600cfg VARIABLE=prev_temp VALUE={printer.extruder.target}
        SET_GCODE_VARIABLE MACRO=_m600cfg VARIABLE=runout VALUE=True
        M109 S0
    {% endif %}

################################
############ M600 ##############
################################
[gcode_macro M600]
gcode:
    {% set m600cfg = printer["gcode_macro _m600cfg"] %}
    SET_IDLE_TIMEOUT TIMEOUT=7200 ; Increase idle timeout
    {% if printer.idle_timeout.state == "Printing" %}
        PAUSE ; Pause printing
    {% else %}
        CG28 ; Home all axes
    {% endif %}
    {% if m600cfg.led_status == True %}
        STATUS_M600
    {% endif %}
    _FILAMENT_PARK
    {% if m600cfg.audio_status == True %}
        ALERT_BEEP_ON
    {% endif %}
    # Check if this is slicer-initiated
    {% if m600cfg.cold_start == False and m600cfg.runout == False %}
        SET_IDLE_TIMEOUT TIMEOUT=3600
        M109 S0
        M{m600cfg.output|int} Filament Change
    {% endif %}
    # Reset check variable
    SET_GCODE_VARIABLE MACRO=_m600cfg VARIABLE=runout VALUE=False

################################
####### UNLOAD_FILAMENT ########
################################
[gcode_macro UNLOAD_FILAMENT]
gcode:
    {% set m600cfg = printer["gcode_macro _m600cfg"] %}
    {% set LENGTH = params.LENGTH|default(m600cfg.unload_length)|float %} ; Unload length
    {% set TARGET = params.TARGET|default(m600cfg.default_temp)|float %} ; Unload temperature
    ##################
    {% if m600cfg.audio_status == True %}
        ALERT_BEEP_OFF
    {% endif %}
    {% set cur_temp = printer.extruder.temperature|float %} ; Current temperature
    {% set cur_targ = printer.extruder.target|int %}        ; Current target
    {% if printer.configfile.config.extruder.min_extrude_temp is defined %}
        {% set min_temp = printer.configfile.config.extruder.min_extrude_temp|int %}
    {% else %}
        {% set min_temp = 170 %}
    {% endif %}
    {% if m600cfg.prev_temp != 0 %}
        {% set TARGET = m600cfg.prev_temp %}
    {% elif params.TARGET is defined and params.TARGET|int > min_temp %} ; If current temp is below target
        {% set TARGET = params.TARGET|int|default(m600cfg.default_temp) %}
    {% endif %}
    G28 ; Home all axes if not already homed
    {% if cur_temp < (TARGET-5) %}
        {% if m600cfg.led_status == True %}
            STATUS_HEATING
        {% endif %}
        M{m600cfg.output|int} Heating nozzle...
        M109 S{TARGET} ; Heat nozzle to target temperature
    {% endif %}
    {% if m600cfg.led_status == True %}
        STATUS_M702
    {% endif %}
    G91 ; Relative positioning
    # Pre-unload to loosen filament
    G1 E5.0 F1200 ; Extrude a bit 
    G1 E3.0 F1600 ; Extrude a bit
    G1 E-13.14 F7000 ; pull hard
    # Unload
    G1 E-{LENGTH} F{m600cfg.fast_speed|int}
    G90 ; Absolute postitioning
    M400
    {% if m600cfg.auto_sensor == True %}
        ENABLEFILAMENTSENSOR
    {% endif %}
    M{m600cfg.output|int} Unload Complete.
    {% if m600cfg.led_status == True %}
        STATUS_BUSY
    {% endif %}

################################
####### INSERT_FILAMENT ########
################################
[gcode_macro _INSERT_FILAMENT]
gcode:
    {% set m600cfg = printer["gcode_macro _m600cfg"] %}
    M{m600cfg.output|int} Filament Detected!
    {% if m600cfg.auto_load == True %}
        LOAD_FILAMENT
    {% endif %}

################################
######## LOAD_FILAMENT #########
################################
[gcode_macro LOAD_FILAMENT]
gcode:
    {% set m600cfg = printer["gcode_macro _m600cfg"] %}
    {% set DELAY = params.DELAY|default(m600cfg.load_delay)|int %}
    {% set SLOW = params.SLOW|default(m600cfg.load_slow)|float %} ; Purge amount
    {% set FAST = params.FAST|default(m600cfg.load_fast)|float %} ; Load length
    ##################
    {% set cur_temp = printer.extruder.temperature|float %} ; Current temperature
    {% set cur_targ = printer.extruder.target|int %}        ; Current target
    {% if printer.configfile.config.extruder.min_extrude_temp is defined %}
        {% set min_temp = printer.configfile.config.extruder.min_extrude_temp|int %}
    {% else %}
        {% set min_temp = 170 %}
    {% endif %}
    {% if m600cfg.prev_temp != 0 %}
        {% set TARGET = m600cfg.prev_temp %}
    {% elif params.TARGET is defined and params.TARGET|int > min_temp %} ; If current temp is below target
        {% set TARGET = params.TARGET|int|default(220) %}
    {% else %}
        {% set TARGET = 220 %}
    {% endif %}
    {% if printer.extruder.target < min_temp %} ; Verify extruder is hot enough
        {% set TARGET = m600cfg.default_temp %} ; Heat up to default temp
    {% else %}
        {% set TARGET = printer.extruder.target %}
    {% endif %}
    CG28 ; Home all axes if not already homed
    {% if cur_temp < (TARGET-5) %}
        {% if m600cfg.led_status == True %}
            STATUS_HEATING
        {% endif %}
        M{m600cfg.output|int} Heating nozzle...
        M109 S{TARGET} ; Heat nozzle to target temperature
    {% endif %}
    {% if m600cfg.led_status == True %}
        STATUS_M701
    {% endif %}
    {% if DELAY > 0 %}
        G4 P{DELAY*1000}
    {% endif %}
    M{m600cfg.output|int}  LOADING...
    G91 ; Relative positioning
    G1 E25.0 F{m600cfg.med_speed|int} ; pre-load
    G1 E{FAST} F{m600cfg.fast_speed|int} ; load up to hotend
    G4 P900 ; wait a moment
    G1 E{SLOW} F{m600cfg.slow_speed|int} ; purge to change filament
    G1 E{m600cfg.post_load_retraction|float}  F{m600cfg.slow_speed|int} ; retract a little
    G90 ; Absolute postitioning
    M400
    {% if m600cfg.coldstart == True %}
        M{m600cfg.output|int} Cooling nozzle...
        M109 S0
        SET_GCODE_VARIABLE MACRO=_m600cfg VARIABLE=coldstart VALUE=False
        {% if m600cfg.auto_sensor == True %}
            DISABLEFILAMENTSENSOR
        {% endif %}
    {% endif %}
    SET_GCODE_VARIABLE MACRO=_m600cfg VARIABLE=prev_temp VALUE=0
    SET_IDLE_TIMEOUT TIMEOUT=900 ; Return idle timeout to normal
    {% if m600cfg.audio_status == True %}
        CHANGE_TUNE
    {% endif %}
    M{m600cfg.output|int} Load Complete
    {% if m600cfg.led_status == True %}
        STATUS_READY
    {% endif %}


################################
############ PURGE #############
################################
[gcode_macro PURGE]
gcode:
    {% set m600cfg = printer["gcode_macro _m600cfg"] %}
    {% set LENGTH = params.LENGTH|default(m600cfg.purge_length)|float %} ; Purge length
    ##################
    {% set cur_temp = printer.extruder.temperature|float %} ; Current temperature
    {% set cur_targ = printer.extruder.target|int %}        ; Current target
    {% if printer.configfile.config.extruder.min_extrude_temp is defined %}
        {% set min_temp = printer.configfile.config.extruder.min_extrude_temp|int %}
    {% else %}
        {% set min_temp = 170 %}
    {% endif %}
    {% if m600cfg.prev_temp != 0 %}
        {% set TARGET = m600cfg.prev_temp %}
    {% elif params.TARGET is defined  %} ; If current temp is below target
        {% set TARGET = params.TARGET|int %}
    {% endif %}
    {% if printer.extruder.target < min_temp %} ; Verify extruder is hot enough
        {% set TARGET = m600cfg.default_temp %} ; Heat up to default temp
    {% endif %}
    {% if m600cfg.led_status == True %}
        STATUS_HEATING
    {% endif %}
    M{m600cfg.output|int} Heating nozzle...
    M109 S{TARGET} ; Heat nozzle to target temperature
    {% if m600cfg.led_status == True %}
        STATUS_M701
    {% endif %}
    M{m600cfg.output|int} PURGING..
    G91 ; Relative positioning
    G1 E{LENGTH} F{m600cfg.slow_speed|int} ; Purge filament
    G90 ; Absolute postitioning
    M400
    M109 S{cur_targ} ; Return target temp to previous value
    M{m600cfg.output|int} Purge Complete
    {% if m600cfg.led_status == True %}
        STATUS_READY
    {% endif %}

################################
######## NOZZLE_CHANGE #########
################################
## This macro is used to change the nozzle on the printer
## It prepares the printhead by heating the nozzle to the
## apppropriate temperature and unloading the filament.
## Then the printhead is parked in a convenient position for nozzle changes.
[gcode_macro NOZZLE_CHANGE]
description: Prepare the printer for a nozzle change
gcode:
    {% set m600cfg = printer["gcode_macro _m600cfg"] %} ; get m600cfg variables
    CG28 ; Home all axes if not already homed
    M{m600cfg.output|int} Nozzle Change
    MAINTENANCE ; Park the toolhead in a convenient position
    UNLOAD_FILAMENT ; Unload filament
    M{m600cfg.output|int} Change nozzle now and run NOZZLE_CHANGE_DONE when finished

[gcode_macro NOZZLE_CHANGE_DONE]
description: Complete the nozzle change
gcode:
    {% set m600cfg = printer['gcode_macro _m600cfg'] %} ; get m600cfg variables
    LOAD_FILAMENT ; Load filament
    M104 S0 ; Turn off extruder heater
    M{m600cfg.output|int} Nozzle Change Complete

################################
########### PARKING ############
################################

# Used to park the toolhead for filament changes
[gcode_macro _FILAMENT_PARK]
gcode:
    {% set m600cfg = printer["gcode_macro _m600cfg"] %}
	M{m600cfg.output|int} Parking toolhead...
	SET_GCODE_VARIABLE MACRO=_m600cfg VARIABLE=prev_temp VALUE={printer.extruder.target}
    G91
	{% if printer.toolhead.position.z|float + m600cfg.z|float < printer.configfile.config["stepper_z"]["position_max"]|float %}
		{% if  printer.toolhead.position.z < m600cfg.zmin|int %}
            G1 Z{m600cfg.zmin|int-printer.toolhead.position.z|int}
		{% else %}
            SAVE_GCODE_STATE NAME=save_state
            G1 Z{m600cfg.z|int}
            RESTORE_GCODE_STATE NAME=save_state
        {% endif %}
	{% endif%}
	G90
	G1 X{m600cfg.x|int} Y{m600cfg.y|int} F{m600cfg.park_speed|int}

## MAINTENANCE parking
[gcode_macro MAINTENANCE]
description: Move the toolhead to a convenient position for working on it
variable_maint_x: -1
variable_maint_y: -1
variable_maint_z: -1
gcode:
    {% set m600cfg = printer['gcode_macro _m600cfg'] %} ; get m600cfg variables
    {% set config = printer.configfile.settings %} ; get realtime configfile settings
    {% set max_x = config["stepper_x"]["position_max"]|float %} ; get max x position
    {% set max_y = config["stepper_y"]["position_max"]|float %} ; get max y position
    {% set max_z = config["stepper_z"]["position_max"]|float %} ; get max z position
    {% set mid_x = max_x / 2.0 %} ; get middle of x axis
    {% set mid_y = max_y / 2.0 %} ; get middle of y axis
    {% set mid_z = max_z / 2.0 %} ; get middle of z axis
    {% if maint_x < 0 or maint_y < 0 or maint_z < 0 %} ; if maintenance position is not defined move to middle of bed
        {% set move_x = mid_x %} ; use middle of x axis
        {% set move_y = mid_y %} ; use middle of y axis
        {% set move_z = mid_z %} ; use middle of z axis
    {% else %} ; otherwise,  move to defined positions
        {% set move_x = maint_x %} ; get maintenance x position
        {% set move_y = maint_y %} ; get maintenance y position
        {% set move_z = maint_z %} ; get maintenance z position
    {% endif %}
    CG28 ; Home all axes (if not already homed)
    G0 X{move_x} Y{move_y} Z{move_z} F3000 ; Move to maintenance position
    M{m600cfg.output|int} Maintenance position reached

################################
########### HOMING #############
################################

## Only home if not homed
[gcode_macro CG28]
variable_output: 118 ; Output method for status feedback
gcode:
    {% if "x" in rawparams|string|lower %} ; if x is in rawparams
        {% set X = True %} ; set x flag
    {% endif %}
    {% if "y" in rawparams|string|lower %} ; if y is in rawparams
        {% set Y = True %} ; set y flag
    {% endif %}
    {% if "z" in rawparams|string|lower %} ; if z is in rawparams
        {% set Z = True %} ; set z flag
    {% endif %}
    {% if rawparams|string|lower == "" %} ; if no parameters are defined
        {% set ALL = True %} ; set all flag
        {% set X = True %}   ; set x flag
        {% set Y = True %}   ; set y flag
        {% set Z = True %}   ; set z flag
    {% endif %}
    {% if printer.toolhead.homed_axes != "xyz" %} ; if not homed
        {% if "x" not in printer.toolhead.homed_axes %} ; if x is not homed
            {% set home_x = True %} ; set home_x flag
        {% endif %}
        {% if "y" not in printer.toolhead.homed_axes %} ; if y is not homed
            {% set home_y = True %} ; set home_y flag
        {% endif %}
        {% if "z" not in printer.toolhead.homed_axes %} ; if z is not homed
            {% set home_z = True %} ; set home_z flag
        {% endif %}

        {% if home_x == True and home_y == True and home_z == True %} ; if all axes need to be homed
            {% if ALL == True %} ; if all axes are being homed
                M{output} Homing all axes
                G28 ; Home all axes
            {% else %} ; if only some axes are being homed
                {% if X == True %} ; if x is being homed
                    M{output} Homing X axis
                    G28 X ; Home x axis
                {% endif %}
                {% if Y == True %} ; if y is being homed
                    M{output} Homing Y axis
                    G28 Y ; Home y axis
                {% endif %}
                {% if Z == True %} ; if z is being homed
                    M{output} Homing Z axis
                    G28 Z ; Home z axis
                {% endif %}
            {% endif %}
        {% else %} ; if only some axes need to be homed
            {% if home_x == True %} ; if x needs to be homed
                {% if X == True %} ; if x is being homed
                    M{output} Homing X axis
                    G28 X ; Home x axis
                {% endif %}
            {% endif %}
            {% if home_y == True %} ; if y needs to be homed
                {% if Y == True %} ; if y is being homed
                    M{output} Homing Y axis
                    G28 Y ; Home y axis
                {% endif %}
            {% endif %}
            {% if home_z == True %} ; if z needs to be homed
                {% if Z == True %} ; if z is being homed
                    M{output} Homing Z axis
                    G28 Z ; Home z axis
                {% endif %}
            {% endif %}
        {% endif %}
    {% else %} ; if already homed
        M{output} All axes are homed
    {% endif %}


################################
############ AUDIO #############
################################

# Audio alert macros
[delayed_gcode alert_beeper]
gcode:
    {% set m600cfg = printer["gcode_macro _m600cfg"] %}
    {m600cfg.audio_macro} ; Play alert tone
    UPDATE_DELAYED_GCODE ID=alert_beeper DURATION={m600cfg.audio_freq|int}
# Start the alert beep cycle
[gcode_macro ALERT_BEEP_ON]
gcode:
    UPDATE_DELAYED_GCODE ID=alert_beeper DURATION=1
# Stop the alert beep cycle
[gcode_macro ALERT_BEEP_OFF]
gcode:
    UPDATE_DELAYED_GCODE ID=alert_beeper DURATION=0

################################
########## TOGGLING ############
################################

# Disable filament sensor at startup
[delayed_gcode AUTO_DISABLEFILAMENTSENSOR]
initial_duration: 1
gcode:
    {% set m600cfg = printer["gcode_macro _m600cfg"] %}
    {% if m600cfg.auto_sensor == True %} ; If automated sensor feature is enabled
        SET_FILAMENT_SENSOR SENSOR={m600cfg.sensor_name} ENABLE=0 ; Disable sensor
    {% endif %}

# Enable filament sensor
[gcode_macro ENABLEFILAMENTSENSOR]
description: Activates filament sensor   
gcode:
    {% set m600cfg = printer["gcode_macro _m600cfg"] %}
    {% set SENSOR = params.SENSOR|default(m600cfg.sensor_name) %} ; get sensor
    M{m600cfg.output|int} Enabling filament sensor
    SET_FILAMENT_SENSOR SENSOR={SENSOR} ENABLE=1

# Disable filament sensor
[gcode_macro DISABLEFILAMENTSENSOR]
description: Deactivates filament sensor
gcode:
    {% set m600cfg = printer["gcode_macro _m600cfg"] %}
    {% set SENSOR = params.SENSOR|default(m600cfg.sensor_name) %} ; get sensor
    M{m600cfg.output|int} Disabling filament sensor
    SET_FILAMENT_SENSOR SENSOR={SENSOR} ENABLE=0

################################
########### OUTPUT #############
################################

# This feature is used for sending status messages to the console
[respond]

# This feature is used for sending status messages to the display
[display_status]

# This macro is used for silencing status messages
[gcode_macro M116]
description: Silent status feedback
gcode:

###############################
###                         ###
###  Sample Configurations  ###
###                         ###
###############################

###############################
### Filament Switch Sensor ####
### https://www.klipper3d.org/Config_Reference.html#filament_switch_sensor ###
###############################
#[filament_switch_sensor filament_sensor]
#switch_pin: ^PB6
#pause_on_runout: False #pause handled by macro
#runout_gcode:
#  FILAMENT_RUNOUT
#insert_gcode:
#  _INSERT_FILAMENT

###############################
### Filament Motion Sensor ####
### https://www.klipper3d.org/Config_Reference.html#filament_motion_sensor ###
###############################
#[filament_motion_sensor smart_filament_sensor]
#switch_pin: ^PB6
#detection_length: 7.0
#extruder: extruder
#pause_on_runout: False #pause handled by macro
#runout_gcode:
#  FILAMENT_RUNOUT
#insert_gcode:
#  _INSERT_FILAMENT


###############################
###                         ###
###      STATUS MACROS      ###
###                         ###
###############################
# STATUS_READY               - LED Ready/Idle State
# STATUS_BUSY                - LED Busy State
# STATUS_HEATING             - LED Extruder Heating State
# STATUS_M600                - LED Runout State
# STATUS_701                 - LED Filament Load State
# STATUS_702                 - LED Filament Unload State
# TELEGRAM_FILAMENT_RUNOUT   - Telegram Alert for runout
# CHANGE_TUNE                - Audio Alert tone

```

</details>


7. [Mise à l'origine sans interrupteur de fin de course](./MyConfiguration/macros/zippy/sensorless_homing_override.cfg)

<details>

```
# Fully featured homing override for sensorless (and sensored!) homing.

# NOTE: As safe_z_home is incompatible with homing_overide:
#   All of the SzH config settings have been replicated below.
#   You can set the values you previously used in SzH to mimic the behavior.
#   Many additional values can also be configured.
#   This makes for a very flexible/customizable homing suite.
#   The latest release supports

# Release Notes: 2022-10-21
# Stable Release 1.3.1
# 
# This set of macros and homing_override will make giving up safe_z_home easy!
# The CONFIGURATION section at the start contains parameters for all your favorite 
# safe_z_home options as well as many addition ones!
# 
# This is specifically targeted towards sensorsless homing builds
# and it allows you to fully customize the behavior
# and extra goodies like:
# 
# - stepper_homing_current
# - "unsafe" pre-homing z-hop height/speed
# - XY homing "bounce" speed/distance
# - post-z-homing z-hop speed/height
# - custom homing acceleration
# 
# Set BOUNCE to 0 to disable the bounce feature.
# 
# With the latest update you can now set CURRENTLESS to 1 to use this override
# without changing the stepper current. This allows this override to be used with
# drivers that cannot set a different current.

[homing_override]
axes: xyz
set_position_z: 0
gcode:
    ######## CONFIGURATION VALUES #######
    {% set CURRENTLESS = 0 %}           # Set to 1 for regular homing
    {% set PROBE_X = 100 %}             # The X coordinate for safe z-homing
    {% set PROBE_Y = 100 %}             # The Y coordinate for safe z-homing
    {% set PROBE_XY_SPEED = 50 %}       # The travel speed when moving to those coordinates
    {% set MOVE_TO_PREVIOUS = False %}  # Save and return to the previous position after homing
    ############# NOTE ################## Set move to prev speed to 0 to use previous gcode speed
    {% set MOVE_TO_PREV_SPEED = 50 %}   # Speed at which to return to previous position
    {% set HOMING_BOUNCE = 5.0 %}       # The amount to "bounce" after hitting endstops
    {% set BOUNCE_SPEED = 25 %}         # The speed to "bounce" after hitting endstops
    {% set Z_HOP = 5 %}                 # The Z-hop distance after homing Z
    {% set Z_HOP_SPEED = 10 %}          # The speed of Z-hop after homing Z
    ############# NOTE ################## Only use current values within the specs of your steppers
    {% set X_HOMING_CUR = 0.500 %}      # The X-axis homing current (in Amps)
    {% set Y_HOMING_CUR = 0.500 %}      # The Y-axis homing current (in Amps)
    {% set HOMING_ACCEL = 500 %}        # The homing acceleration (in mm/s/s)
    ############ WARNING ################ The pause must be long enough for the drivers to apply the current
    {% set PAUSE = 1000 %}              # Miliseconds to pause after changing current
    ############ DANGER ################# Be careful with these as they are performed before homing
    {% set SAFETY_HOP = 10 %}           # The "unsafe" z-hop before homing XY
    {% set SAFETY_HOP_SPEED = 5 %}      # The "unsafe" z-hop speed
    #####################################

    # Read the current acceleration max
    {% set cur_accel = printer.toolhead.max_accel %}
    {% set cur_accel_to_decel = printer.toolhead.max_accel_to_decel %}
    # Read requested homing axis
    {% set requested = {'x': False,
                        'y': False,
                        'z': False} %}
    {% if   not 'X' in params
        and not 'Y' in params 
        and not 'Z' in params %}
        {% set X, Y, Z = True, True, True %}
    {% else %}
        {% if 'X' in params %}
            {% set X = True %}
            {% set null = requested.update({'x': True}) %}
        {% endif %}       
        {% if 'Y' in params %}
            {% set Y = True %}
            {% set null = requested.update({'y': True}) %}
        {% endif %}     
        {% if 'Z' in params %}
            {% set Z = True %}
            {% set null = requested.update({'z': True}) %}
        {% endif %}        
    {% endif %}
    
    #STATUS_HOMING

    # Pre-homing "unsafe" z-hop to protect bed
    {% if not "xyz" in printer.toolhead.homed_axes %}
        G1 Z{SAFETY_HOP} F{(SAFETY_HOP_SPEED * 60)}
    {% endif %}

    # Save state for MOVE_TO_PREVIOUS
    {% if MOVE_TO_PREVIOUS %}
        SAVE_GCODE_STATE NAME=homing
    {% endif %}

    # X and Y homing
    {% if CURRENTLESS != 1 %}
        {% if X and Y %}
            SENSORLESS_HOME_ALL X_CUR={X_HOMING_CUR} Y_CUR={Y_HOMING_CUR} ACCEL={HOMING_ACCEL} BOUNCE={HOMING_BOUNCE} BOUNCE_SPEED={BOUNCE_SPEED} PAUSE={PAUSE}
        {% elif X %}
            SENSORLESS_HOME_X CURRENT={X_HOMING_CUR} ACCEL={HOMING_ACCEL} BOUNCE={HOMING_BOUNCE} BOUNCE_SPEED={BOUNCE_SPEED} PAUSE={PAUSE}
        {% elif Y %}
            SENSORLESS_HOME_Y CURRENT={Y_HOMING_CUR} ACCEL={HOMING_ACCEL} BOUNCE={HOMING_BOUNCE} BOUNCE_SPEED={BOUNCE_SPEED} PAUSE={PAUSE}
        {% endif %}
    {% else %}
        {% if X and Y %}
            SENSOR_HOME_ALL ACCEL={HOMING_ACCEL} BOUNCE={HOMING_BOUNCE} BOUNCE_SPEED={BOUNCE_SPEED} PAUSE={PAUSE}
        {% elif X %}
            SENSOR_HOME_X ACCEL={HOMING_ACCEL} BOUNCE={HOMING_BOUNCE} BOUNCE_SPEED={BOUNCE_SPEED} PAUSE={PAUSE}
        {% elif Y %}
            SENSOR_HOME_Y ACCEL={HOMING_ACCEL} BOUNCE={HOMING_BOUNCE} BOUNCE_SPEED={BOUNCE_SPEED} PAUSE={PAUSE}
        {% endif %}
    {% endif %}

    # Z Homing
    {% if Z %}
        G1 X{PROBE_X} Y{PROBE_Y} F{(PROBE_XY_SPEED * 60)} # Move to safe coordinates
        G28 Z # Home Z
        G1 Z{Z_HOP} F{(Z_HOP_SPEED * 60)} # Post z-home z-hop
    {% endif %}

    # Restore state for MOVE_TO_PREVIOUS
    {% if MOVE_TO_PREVIOUS %}
        {% if MOVE_TO_PREV_SPEED == 0 %}
            RESTORE_GCODE_STATE NAME=homing MOVE=1
        {% else %}
            RESTORE_GCODE_STATE NAME=homing MOVE=1 MOVE_SPEED={MOVE_TO_PREV_SPEED}
        {% endif %}
    {% endif %}

    # Reset any acceleration changes
    {% if printer.toolhead.max_accel != cur_accel %}
        SET_VELOCITY_LIMIT ACCEL={cur_accel} ACCEL_TO_DECEL={cur_accel_to_decel}
    {% endif %}

    #STATUS_READY



# SENSORLESS HOMING

[gcode_macro SENSORLESS_HOME_ALL]
description: Home XY with modified current
gcode:
    {% set HOME_CUR_X = params.X_CUR|default(0.250)|float %}
    {% set HOME_CUR_Y = params.Y_CUR|default(0.250)|float %}
    {% set HOME_ACCEL = params.ACCEL|default(500)|float %}
    {% set BOUNCE = params.BOUNCE|default(10)|float %}
    {% set BOUNCE_SPEED = params.BOUNCE_SPEED|default(20)|float %}
    {% set driver_config_x = printer.configfile.settings['tmc2209 stepper_x'] %}
    {% set driver_config_y = printer.configfile.settings['tmc2209 stepper_y'] %}
    {% set RUN_CUR_X = driver_config_x.run_current %}
    {% set RUN_CUR_Y = driver_config_y.run_current %}
    {% set PAUSE = params.PAUSE|default(2000)|int %}

    # Set current for sensorless homing
    SET_TMC_CURRENT STEPPER=stepper_x CURRENT={HOME_CUR_X}
    SET_TMC_CURRENT STEPPER=stepper_y CURRENT={HOME_CUR_Y}
    # Set homing acceleration
    SET_VELOCITY_LIMIT ACCEL={HOME_ACCEL} ACCEL_TO_DECEL={(HOME_ACCEL * 0.5)}
    # Pause to ensure driver stall flag is clear
    G4 P{PAUSE}
    # Home X
    G28 X0
    {% if BOUNCE %}
        # Move away
        G91
        G1 X{BOUNCE} F{(BOUNCE_SPEED * 60)}
        G90
    {% endif %}
    # Home Y
    G28 Y0
    {% if BOUNCE %}
        # Move away
        G91
        G1 Y{BOUNCE} F{(BOUNCE_SPEED * 60)}
        G90
    {% endif %}
    # Set current during print
    SET_TMC_CURRENT STEPPER=stepper_x CURRENT={RUN_CUR_X}
    SET_TMC_CURRENT STEPPER=stepper_y CURRENT={RUN_CUR_Y}
    # Pause to ensure driver stall flag is clear
    G4 P{PAUSE}


[gcode_macro SENSORLESS_HOME_X]
description: Home X with modified current
gcode:
    {% set HOME_CUR = params.CURRENT|default(0.250)|float %}
    {% set HOME_ACCEL = params.ACCEL|default(500)|float %}
    {% set BOUNCE = params.BOUNCE|default(10)|float %}
    {% set BOUNCE_SPEED = params.BOUNCE_SPEED|default(20)|float %}
    {% set driver_config = printer.configfile.settings['tmc2209 stepper_x'] %}
    {% set RUN_CUR = driver_config.run_current %}
    {% set PAUSE = params.PAUSE|default(2000)|int %}

    # Set current for sensorless homing
    SET_TMC_CURRENT STEPPER=stepper_x CURRENT={HOME_CUR}
    # Set homing acceleration
    SET_VELOCITY_LIMIT ACCEL={HOME_ACCEL} ACCEL_TO_DECEL={(HOME_ACCEL * 0.5)}
    # Pause to ensure driver stall flag is clear
    G4 P{PAUSE}
    # Home
    G28 X0
    {% if BOUNCE %}
        # Move away
        G91
        G1 X{BOUNCE} F{(BOUNCE_SPEED * 60)}
        G90
    {% endif %}
    # Set current during print
    SET_TMC_CURRENT STEPPER=stepper_x CURRENT={RUN_CUR}
    # Pause to ensure driver stall flag is clear
    G4 P{PAUSE}


[gcode_macro SENSORLESS_HOME_Y]
description: Home Y with modified current
gcode:
    {% set HOME_CUR = params.CURRENT|default(0.250)|float %}
    {% set HOME_ACCEL = params.ACCEL|default(500)|float %}
    {% set BOUNCE = params.BOUNCE|default(10)|float %}
    {% set BOUNCE_SPEED = params.BOUNCE_SPEED|default(20)|float %}
    {% set driver_config = printer.configfile.settings['tmc2209 stepper_y'] %}
    {% set RUN_CUR = driver_config.run_current %}
    {% set PAUSE = params.PAUSE|default(2000)|int %}
    
    # Set current for sensorless homing
    SET_TMC_CURRENT STEPPER=stepper_y CURRENT={HOME_CUR}
    # Set homing acceleration
    SET_VELOCITY_LIMIT ACCEL={HOME_ACCEL} ACCEL_TO_DECEL={(HOME_ACCEL * 0.5)}
    # Pause to ensure driver stall flag is clear
    G4 P{PAUSE}
    # Home
    G28 Y0
    {% if BOUNCE %}
        # Move away
        G91
        G1 Y{BOUNCE} F{(BOUNCE_SPEED * 60)}
        G90
    {% endif %}
    # Set current during print
    SET_TMC_CURRENT STEPPER=stepper_y CURRENT={RUN_CUR}
    # Pause to ensure driver stall flag is clear
    G4 P{PAUSE}



# HOME WITH ENDSTOPS

[gcode_macro SENSOR_HOME_ALL]
description: Home XY
gcode:
    {% set HOME_ACCEL = params.ACCEL|default(500)|float %}
    {% set BOUNCE = params.BOUNCE|default(10)|float %}
    {% set BOUNCE_SPEED = params.BOUNCE_SPEED|default(20)|float %}
    {% set PAUSE = params.PAUSE|default(2000)|int %}

    # Set homing acceleration
    SET_VELOCITY_LIMIT ACCEL={HOME_ACCEL} ACCEL_TO_DECEL={(HOME_ACCEL * 0.5)}
    # Pause to ensure driver stall flag is clear
    G4 P{PAUSE}
    # Home X
    G28 X0
    {% if BOUNCE %}
        # Move away
        G91
        G1 X{BOUNCE} F{(BOUNCE_SPEED * 60)}
        G90
    {% endif %}
    # Home Y
    G28 Y0
    {% if BOUNCE %}
        # Move away
        G91
        G1 Y{BOUNCE} F{(BOUNCE_SPEED * 60)}
        G90
    {% endif %}
    # Pause to ensure driver stall flag is clear
    G4 P{PAUSE}


[gcode_macro SENSOR_HOME_X]
description: Home X
gcode:
    {% set HOME_ACCEL = params.ACCEL|default(500)|float %}
    {% set BOUNCE = params.BOUNCE|default(10)|float %}
    {% set BOUNCE_SPEED = params.BOUNCE_SPEED|default(20)|float %}
    {% set PAUSE = params.PAUSE|default(2000)|int %}

    # Set homing acceleration
    SET_VELOCITY_LIMIT ACCEL={HOME_ACCEL} ACCEL_TO_DECEL={(HOME_ACCEL * 0.5)}
    # Pause to ensure driver stall flag is clear
    G4 P{PAUSE}
    # Home
    G28 X0
    {% if BOUNCE %}
        # Move away
        G91
        G1 X{BOUNCE} F{(BOUNCE_SPEED * 60)}
        G90
    {% endif %}
    # Pause to ensure driver stall flag is clear
    G4 P{PAUSE}



[gcode_macro SENSOR_HOME_Y]
description: Home Y
gcode:
    {% set HOME_ACCEL = params.ACCEL|default(500)|float %}
    {% set BOUNCE = params.BOUNCE|default(10)|float %}
    {% set BOUNCE_SPEED = params.BOUNCE_SPEED|default(20)|float %}
    {% set PAUSE = params.PAUSE|default(2000)|int %}

    # Set homing acceleration
    SET_VELOCITY_LIMIT ACCEL={HOME_ACCEL} ACCEL_TO_DECEL={(HOME_ACCEL * 0.5)}
    # Pause to ensure driver stall flag is clear
    G4 P{PAUSE}
    # Home
    G28 Y0
    {% if BOUNCE %}
        # Move away
        G91
        G1 Y{BOUNCE} F{(BOUNCE_SPEED * 60)}
        G90
    {% endif %}
    # Pause to ensure driver stall flag is clear
    G4 P{PAUSE}

```

</details>




