## Klipper

- Calibration Pid [lien Klipper](https://www.klipper3d.org/fr/G-Codes.html#pid_calibrate)
```
PID_CALIBRATE HEATER=extruder TARGET=215
PID_CALIBRATE HEATER=heater_bed TARGET=50
```

- Calibration de l'avance à la pression (pressure advance) [lien Klipper](https://www.klipper3d.org/fr/Pressure_Advance.html#avance-a-la-pression) 
  - lancer cette commande
  ```
  SET_VELOCITY_LIMIT SQUARE_CORNER_VELOCITY=1 ACCEL=500
  ```
  - puis celle-ci (en fonction du type d'extrudeur)
    - Direct Drive
    ```
    TUNING_TOWER COMMAND=SET_PRESSURE_ADVANCE PARAMETER=ADVANCE START=0 FACTOR=.005
    ```  
    - Bowden
    ```
    TUNING_TOWER COMMAND=SET_PRESSURE_ADVANCE PARAMETER=ADVANCE START=0 FACTOR=.020
    ```
  - la valeur du paramètre `pressure_advance` se calcule de la manière suivante `pressure_advance = <début> + <hauteur_mesurée> * <facteur>` (Exemple: 0 + 12,90 * 0,020 = 0,258 ) 

- Vérifier l'état d'un pilote [lien Klipper](https://www.klipper3d.org/fr/TMC_Drivers.html#pilotes-de-moteur-pas-a-pas-tmc)

  - Vérifier l'état du pilote TMC en mode SPI/UART (remplacer le nom du pilote `extruder` par celui à tester)

  ```
  DUMP_TMC STEPPER=extruder
  ```
- Vérifier les moteurs [lien Klipper](https://www.klipper3d.org/fr/Config_checks.html#verifier-les-moteurs-pas-a-pas)
  - Utiliser la commande STEPPER_BUZZ pour vérifier la connectivité de chaque moteur pas à pas. D'abord, déplacez manuellement l'axe à vérifier
 jusqu'au point central, puis exécuter la commande STEPPER_BUZZ STEPPER=stepper_x. La commande STEPPER_BUZZ déplace l'axe X d'un millimètre dans
la direction positive, puis revient à sa position initiale. (Si la position de la limite est définie à position_endstop=0, le stepper s'éloignera
 de la limite au début de chaque mouvement). Cette action sera exécutée dix fois.
```
STEPPER_BUZZ STEPPER=stepper_x
STEPPER_BUZZ STEPPER=stepper_y
STEPPER_BUZZ STEPPER=stepper_z
``` 
- Calcul du pas de l'extrudeur [lien Klipper](https://www.klipper3d.org/fr/Rotation_Distance.html#distance-de-rotation)
  - S'assurer d'abord que l'extrudeur fonctionne correctement, vérifier que le rapport d'engrenage ( `full_steps_per_rotation` + `gear_ratio` si utilisé) est correct,
 sinon la valeur de pas ( `estep` ) de l'extrudeur ne peut pas être calibré.
```
microsteps: 16
full_steps_per_rotation: 200 
rotation_distance: 53.5  #22.6789511	#Bondtech 5mm Drive Gears
# rotation_distance = <full_steps_par_rotation> * <microsteps> / <steps_par_mm>
gear_ratio: 1628:170				# Qidi X-Max 3
```
- Déplacement forcé des moteurs [lien Klipper](https://www.klipper3d.org/fr/G-Codes.html#force_move)
  - Nécessite la section suivante dans **printer.cfg**
```
[force_move]
enable_force_move: true
```
  - [Cette commande](https://www.klipper3d.org/fr/G-Codes.html#force_move_1) permet de contrôler l'un des moteurs pour qu'il fonctionne sans mise à l'origine préalable (homing).
 **Peut être dangereux pour le matériel !**
```
FORCE_MOVE STEPPER=<nom_de_la_configuration> DISTANCE=<valeur> VELOCITE=<valeur> [ACCEL=<valeur>]
```

### Pour aller plus loin

- [Documentation Klipper (en français)](https://www.klipper3d.org/fr/)
- [Klipper Gcodes](https://www.klipper3d.org/fr/G-Codes.html#g-codes)
- [Klipper Avance à la pression](https://www.klipper3d.org/fr/Pressure_Advance.html#avance-a-la-pression)
- [Guide de calibration d'Ellis](https://ellis3dp.com/Print-Tuning-Guide/)
- [Quelques guides intéressants](https://github.com/rootiest/zippy_guides)
- …
