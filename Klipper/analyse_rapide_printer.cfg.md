# Le fichier de configuration : printer.cfg

Qiditech fournit dans ce fichier à la fois:

- la configuration matérielle de tous les composants gérés par le firmware Klipper flashé sur les deux cartes contrôleurs
- un ensemble de macros

Ayant plutôt l'habitude de séparer «serviettes et torchons», [ma première modification](./configuration.md) a été de scinder et
réorganiser ce gros fichiers en deux parties:

- printer.cfg => configuration matérielle uniquement
- qidi_macros.cfg =>les macros QIDI utilisées via une directive [include qidi_macros.cfg] au début du fichier ci-dessus

## Analyse de la configuration matérielle

### MCU

La X-Max 3 gère trois (3) «mcu» (micro controler unit) :

> le principal est celui correspondant au microcontrôleur STM32F402 via une liaison série USB

```
    [mcu]
    # The hardware use USART1 PA10/PA9 connect to RK3328
    serial: /dev/ttyS0
    restart_method: command
```

> le second est celui de la carte fille situé sur la tête, microcontrôleur STM là encore en liaison série USB

```
    [mcu MKS_THR]
    serial:/dev/serial/by-id/usb-Klipper_rp2040_65054E953D866458-if00
```

> le troisième correspond au contrôleur de la carte (le Rockship RK3328) à l'identique d'un Raspberry Pi

```
    [mcu rpi]
    serial: /tmp/klipper_host_mcu
```

### [printer]

La section de configuration (printer) précise la cinématique de l'imprimante, ses accélérations et vitesses maximales    

```
[printer]
kinematics: corexy
max_velocity: 600
max_accel: 20000
max_accel_to_decel: 10000
max_z_velocity: 20
max_z_accel: 500
square_corner_velocity: 8
```

### Pilotes moteurs

On trouve évidemment les déclarations de paramètres des moteurs pilotant les axes (stepper …). Les axes X et Y
utilisent la mise à l'origine sans capteur permise grâce aux pilotes TMC 2209. Exemple pour le pilote de l'axe X :

```
[stepper_x]
…
endstop_pin: tmc2209_stepper_x:virtual_endstop
…
[tmc2209 stepper_x]
…
driver_SGTHRS: 85
…
```

L'utilisation de ce mode nécessite la modification du processus de mise à l'origine via la directive
[homing_override] (réduction du courant envoyé aux pilotes le temps de cette mise à l'origine) :


```
## Modification du processus de mise à l'origine
[homing_override]
set_position_X: 0
set_position_y: 0
set_position_z: 0
axes: xy
gcode:
    {% set HOME_CUR = 1 %}
    {% set driver_config = printer.configfile.settings['tmc2209 stepper_x'] %}
    {% set RUN_CUR = driver_config.run_current %}
    {% set HOLD_CUR = driver_config.hold_current %}
    {% if params.X is defined %}
        SET_TMC_CURRENT STEPPER=stepper_x CURRENT={HOME_CUR * 0.8}
        G28 X
        SET_TMC_CURRENT STEPPER=stepper_x CURRENT={HOME_CUR}     
        BEEP I=1 DUR=100       
        G1 X10 F1200
    {% endif %}
    {% if params.Y is defined %}
        SET_TMC_CURRENT STEPPER=stepper_y CURRENT={HOME_CUR * 0.9}
        G28 Y
        SET_TMC_CURRENT STEPPER=stepper_y CURRENT={HOME_CUR}   
        BEEP I=1 DUR=100          
       G1 Y10 F1200
    {% endif %}
    {% if params.Z is defined %}
#        G90
#        G1 X{printer.toolhead.axis_maximum.x/2 - printer.probe["x_offset"]} Y{printer.toolhead.axis_maximum.y/2 - printer.probe["y_offset"]} F7800
#        G91
        G28 Z
        G1 Z20 F600      
        BEEP I=1 DUR=100      
    {% endif %}
    {% if params.X is undefined %}
    {% if params.Y is undefined %}
    {% if params.Z is undefined %}
    G91
#    G1 Z5 F600    
    G1 X10 F2400
    G1 Y10 F2400
    G4 P2000
    SET_TMC_CURRENT STEPPER=stepper_x CURRENT={HOME_CUR * 0.8}
    G28 X
    SET_TMC_CURRENT STEPPER=stepper_x CURRENT={HOME_CUR}
    BEEP I=1 DUR=100  
    G1 X10 F1200
    SET_TMC_CURRENT STEPPER=stepper_y CURRENT={HOME_CUR * 0.9}
    G28 Y
    SET_TMC_CURRENT STEPPER=stepper_y CURRENT={HOME_CUR}
    BEEP I=1 DUR=100        
    G90
    G1 X{printer.toolhead.axis_maximum.x/2 - printer.probe["x_offset"]} Y{printer.toolhead.axis_maximum.y/2 - printer.probe["y_offset"]} F7800
    G91
    G28 Z
    BEEP I=1 DUR=100  
    G1 Z50  F600
    {% endif %}
    {% endif %}
    {% endif %}
    SET_TMC_CURRENT STEPPER=stepper_x CURRENT={RUN_CUR}
    SET_TMC_CURRENT STEPPER=stepper_y CURRENT={RUN_CUR}
    M204 S10000
```

## Gestion des mises en chauffe et surveillance des températures

### Lit chauffant

```
    [heater_bed]
    heater_pin: PC8
    sensor_type: NTC 100K MGB18-104F39050L32
    sensor_pin: PA0
    max_power: 1.0
    control: pid
    pid_kp: 71.039
    pid_ki: 2.223
    pid_kd: 567.421
    min_temp: -50
    max_temp: 125
```

vérification de ce capteur
    
```
    [verify_heater heater_bed]
    max_error: 200
    check_gain_time: 60
    hysteresis: 5
    heating_gain: 1
```

### Extrudeur

```
    [extruder]
    step_pin: MKS_THR:gpio5
    dir_pin: MKS_THR:gpio4
    enable_pin: !MKS_THR:gpio10
    rotation_distance: 53.5
    gear_ratio: 1628:170				
    microsteps: 16
    full_steps_per_rotation: 200
    nozzle_diameter: 0.400
    filament_diameter: 1.75
    min_temp: 0
    max_temp: 360
    min_extrude_temp: 170
    smooth_time: 0.000001
    heater_pin: MKS_THR:gpio0
    sensor_type: MAX6675
    sensor_pin: MKS_THR:gpio17
    spi_software_sclk_pin: MKS_THR:gpio18
    spi_software_mosi_pin: MKS_THR:gpio19
    spi_software_miso_pin: MKS_THR:gpio16
    max_power: 1.0
    control: pid  
    pid_Kp: 14.734
    pid_Ki: 6.549 
    pid_Kd: 8.288
    pressure_advance: 0.032
    pressure_advance_smooth_time: 0.03
    max_extrude_cross_section: 10
    instantaneous_corner_velocity: 10.000
    max_extrude_only_distance: 100.0
    max_extrude_only_velocity: 5000
    max_extrude_only_accel: 2000
    step_pulse_duration: 0.000002
```

vérification de ce capteur

```
    [verify_heater extruder]
    max_error: 120
    check_gain_time: 20
    hysteresis: 5
    heating_gain: 1
```

### Chambre (enceinte / caisson)

```
    [heater_generic chamber]
    heater_pin: PB10
    max_power: 1.0
    sensor_type: NTC 100K MGB18-104F39050L32
    sensor_pin: PA1
    control: watermark
    max_delta: 1.0
    min_temp: -100
    max_temp: 70
```
déclenchement du ventilateur associé à ce capteur
```
    [temperature_fan chamber]
    pin: PC9
    max_power: 1
    hardware_pwm: false
    off_below:.1
    sensor_type: NTC 100K MGB18-104F39050L32
    sensor_pin: PA1
    control: pid
    pid_kp: 60
    pid_ki: 1
    pid_kd: 900
    pid_deriv_time: 120
    min_temp: 0
    max_temp: 90
    target_temp: 50.0
    max_speed: 1
    min_speed: 0.0
    gcode_id: chamber
```
vérification de ce capteur
```
    [verify_heater chamber]
    max_error: 300
    check_gain_time: 480
    hysteresis: 5
    heating_gain: 1
```

### Ventilateur de refroidissement du radiateur de la tête

```
    [heater_fan hotend_fan]
    pin: MKS_THR:gpio1
    max_power: 1.0
    kick_start_time: 0.5
    heater: extruder
    heater_temp: 50.0
    fan_speed: 1.0
    off_below: 0
```

### Surveillance des températures hôte et MCU

```
    [temperature_sensor RK3328]
    sensor_type: rpi_temperature
    sensor_type: temperature_host
    min_temp: 10
    max_temp: 85

    [temperature_sensor STM32F402]
    sensor_type: temperature_mcu
    min_temp: 10
    max_temp: 85
```

### Ventilateurs

Les ventilateurs sont gérés via des directives [output_pin] et seront donc actionnés via des macros Gcode
en utilisant la commande `SET_PIN PIN=broche_a_actionner VALUE=valeur`

#### Refroidissement du filament (buse) => fan0

```
    [output_pin fan0]
    pin: MKS_THR:gpio2
    pwm: True
    cycle_time: 0.0100
    hardware_pwm: false
    value: 0
    scale: 255
    shutdown_value: 0.0
```

#### Refroidissement du filament (auxilaire) soufflant sur le plateau => fan2

```
    [output_pin fan2]
    pin: PA8
    pwm: True
    cycle_time: 0.0100
    hardware_pwm: false
    value: 0.00
    scale: 255
    shutdown_value: 0.0
```

#### Extraction air interne à travers filtre à charbon actif => fan3

```
    [output_pin fan3]
    pin: PC9
    pwm: True
    cycle_time: 0.0100
    hardware_pwm: false
    value: 0.0
    scale: 255
    shutdown_value: 0.0
```

### Détecteur de fin de filament

Activé par défaut, permet de mettre en pause l'impression quand il n'y a plus de filament.

```
[filament_switch_sensor fila]
pause_on_runout: True
runout_gcode:
            PAUSE
            SET_FILAMENT_SENSOR SENSOR=fila ENABLE=1
event_delay: 3.0
pause_delay: 0.5
switch_pin: !PC1
```

Quand une absence de filament est détectée, un message s'affiche sur l'écran, il suffit de suivre les étapes décrites
pour procéder au retrait puis insertion d'un nouveau filament.
Purger le nouveau filament puis reprendre l'impression (testé à deux reprises, en tout cas chez moi, il fonctionne parfaitement).

Le processus de retrait de l'ancien filament s'effectue en trois étapes via l'appel à une macro Gcode M603:

1- extrusion lente d'une petite quantité de filament
2- pause
3- retrait «rapide» de la quantité nécessaire à sortir le filament des roues dentées d'entrainement

```
    [gcode_macro M603]
    description: filament unload
    gcode:
        G92 E0
        G0  E15 F400
        G4  P1000
        G92 E0
        G1  E-80 F800
```
     
A noter que l'extrudeur ne possède pas de levier permettant la libération / l'insertion du filament
=> procéder via des manipulations sur l'écran.
Le mieux est d'extraire le PTFE guidant le filament vers la tête au niveau de celle-ci (pas très pratique
ni facile quand on a des gros doigts ou qu'on imprime avec le caisson totalement fermé).

La chaine Youtube Qiditech propose une vidéo pour le processus de changement de filament (d'autree vidéos
sont également disponibles pour tout ce qui concerne laa amintenance 😉).

### Nivelage du lit d'impression

Le capteur Bltouch est à la fois:

- le dispositif permettant de détecter la mise à l'origine de l'axe Z (remplace l'interrupteur de fin de course)
- une sonde permettant de réaliser la topographie (maillage / mesh) via le palpage du plateau suivant une matrice de points 9x9 (8x8 avec le firmware originel)

```
    [bed_mesh]
    speed: 150
    horizontal_move_z: 10
    mesh_min: 30,15
    mesh_max: 310,310
    probe_count: 9,9
    algorithm: bicubic
    bicubic_tension: 0.2
    mesh_pps: 4, 4

    [bltouch]
    sensor_pin: ^MKS_THR:gpio21
    control_pin: MKS_THR:gpio11
    stow_on_each_sample: False
    x_offset: 28
    y_offset: 4.4
    z_offset: 0.0
    speed: 10 #5
    samples: 2
    samples_result: average
    sample_retract_dist: 3.0
    samples_tolerance: 0.08
    samples_tolerance_retries: 3
```

Une fois le réglage du Zoffset puis de la topographie du plateau faits via l'écran tactile, la cartographie
du plateau (=le maillage palpé) est enregistré  tout à la fin du fichier printer.cfg :

```
#*# <---------------------- SAVE_CONFIG ---------------------->
#*# DO NOT EDIT THIS BLOCK OR BELOW. The contents are auto-generated.
#*#
…
#*#
#*# [bed_mesh default]
#*# version = 1
#*# points =
#*# 	  -0.426250, -0.312500, -0.252500, -0.201250, -0.303750, -0.256250, -0.220000, -0.217500, -0.323750
#*# 	  -0.207500, -0.126250, -0.111250, -0.066250, -0.113750, -0.090000, -0.100000, -0.107500, -0.147500
#*# 	  0.000000, 0.008750, 0.057500, 0.058750, 0.036250, 0.041250, 0.030000, -0.001250, -0.020000
#*# 	  0.071250, 0.086250, 0.126250, 0.153750, 0.127500, 0.122500, 0.108750, 0.072500, 0.038750
#*# 	  0.022500, 0.127500, 0.192500, 0.198750, 0.086250, 0.162500, 0.150000, 0.138750, 0.020000
#*# 	  0.173750, 0.190000, 0.190000, 0.213750, 0.213750, 0.183750, 0.206250, 0.143750, 0.125000
#*# 	  0.165000, 0.200000, 0.210000, 0.256250, 0.210000, 0.175000, 0.178750, 0.123750, 0.145000
#*# 	  0.150000, 0.175000, 0.226250, 0.216250, 0.180000, 0.192500, 0.172500, 0.160000, 0.100000
#*# 	  0.025000, 0.136250, 0.187500, 0.198750, 0.091250, 0.187500, 0.170000, 0.180000, 0.026250
#*# tension = 0.2
#*# min_x = 30.0
#*# algo = bicubic
#*# y_count = 9
#*# mesh_y_pps = 4
#*# min_y = 15.0
#*# x_count = 9
#*# max_y = 309.96
#*# mesh_x_pps = 4
#*# max_x = 310.0
```

Dans l'interface Web Fluidd, on peut visualiser ce maillage.

> A noter que Qiditech gère le «z_offset» via l'écran d’étalonnage puis sauvegarde la valeur trouvée non pas
à la fin du fichier «printer.cfg» mais stocke cette valeur dans le fichier de  configuration de l'écran (config.mksini).
Inconvénient de cette méthode: on ne peut plus utiliser les outils habituels de Klipper (probe_calibrate, …) et
surtout il faut laisser le z_offset à 0 dans la section [bltouch].

### Compensation de résonance

La puce ADXL345 est située sur la carte fille au niveau de la tête. Avec une imprimante CoreXY, comme la X-Max 3,
la calibration s'en trouve facilitée. Mes autres imprimantes non CoreXY (des «bed slinger» = le plateau se
déplace sur l'axe Y), il faut ou deux ADXL345 (un par axe) ou déplacer le matériel de la tête au plateau.

```
[adxl345]
cs_pin: MKS_THR:gpio13
spi_software_sclk_pin: MKS_THR:gpio14
spi_software_mosi_pin: MKS_THR:gpio15
spi_software_miso_pin: MKS_THR:gpio12
axes_map: -x, z, -y

[resonance_tester]
accel_chip: adxl345
probe_points:
    160, 160, 10 
```

Une fois les tests des fréquences de vibrations réalisés, le résultat (type de compensation
et fréquence pour chaque axe ) est enregistré à la fin du printer.cfg dans la section réservée :

```
#*# <---------------------- SAVE_CONFIG ---------------------->
#*# DO NOT EDIT THIS BLOCK OR BELOW. The contents are auto-generated.
#*#
#*# [input_shaper]
#*# shaper_type_x = ei
#*# shaper_freq_x = 53.8
#*# shaper_type_y = zv
#*# shaper_freq_y = 45.2
```

Comme j'ai ajouté l'extension `G-Code Shell Command` (un script Python) de KIAUH (Kiauh est installé
dans le répertoire de l'utilisateur «mks»), créé les scripts shell et les macros Gcode nécessaires
pour produire les graphiques :

```
# Process csv files issued from "input_shaping" to obtain png files
# 
[gcode_macro PROCESS_SHAPER_DATA]
description: process csv file to png
gcode:
    RUN_SHELL_COMMAND CMD=adxl_x
    RUN_SHELL_COMMAND CMD=adxl_y
  
[gcode_shell_command adxl_x]
command: sh /home/mks/klipper_config/scripts/adxl_x.sh 
timeout: 300.
verbose: True

[gcode_shell_command adxl_y]
command: sh /home/mks/klipper_config/scripts/adxl_y.sh 
timeout: 300.
verbose: True

# Pour faire une sauvegarde "régulière" via Github
# https://github.com/th33xitus/kiauh/wiki/How-to-autocommit-config-changes-to-github%3F
#
[gcode_shell_command backup_cfg]
command: sh /home/mks/klipper_config/scripts/autocommit.sh
timeout: 30.
verbose: True

[gcode_macro BACKUP_CFG]
gcode:
    RUN_SHELL_COMMAND CMD=backup_cfg
```

Ce fichier shell_command.cfg est inclus au début du fichier printer.cfg via une directive [include shell_command.cfg].
Un répertoire nommé «scripts» créé dans ~/klipper_config me permet de stocker les scripts shell.
Exemple pour l'axe X (remplacer x par y pour obtenir le script de l'axe Y) :

```bash
#!/bin/sh
#
# Create PNG from csv file issued after INPUT_SHAPING, X axis
#

# Paths
# Qiditech use the old configuration ~/klipper_config
#
DATE=$(date +"%Y%m%d")
SCRIPTS="/home/mks/klipper/scripts/calibrate_shaper.py"
CSV_FILE="/tmp/calibration_data_x_*.csv"
PNG_FILE="/home/mks/klipper_config/calibrations/shaper_calibrate_x_$DATE.png"

$SCRIPTS $CSV_FILE -o $PNG_FILE
```

L'appel de la macro «PROCESS_SHAPER_DATA» dans la console Fluidd permet d'obtenir les graphiques.
Étant enregistrés dans `~/klipper_config/calibrations/`, ils sont facilement téléchargeables sur un matériel
informatique (clic droit sur le fichier, téléchargé)

### Reste de la configuration

Emplacement du stockage de la carte SD virtuelle :

```
[virtual_sdcard]
path: ~/gcode_files
```

Quelques paramètres utiles ( exclusion d'objet, gestion des courbes, délai d'inactivité ) :

```
[exclude_object]

[gcode_arcs]
resolution: 0.1 # 1.0

[idle_timeout]
timeout: 5400 # en secondes
```

Voilà pour l'essentiel du fichier «printer.cfg» 
