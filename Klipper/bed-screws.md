## Ajout maillage

D'origne, le lit d'impression est plutôt bien réglé en sortie d'usine (en tout cas pour mon imprimante).

Au cas ou il faille régler le parallélisme du plateau par rapport aux axes X/Y, la X Max 3 utilisant une sonde de palpage (Bltouch ou Inductif), ce réglage peut être facilité.

La [section suivante](https://www.klipper3d.org/fr/Config_Reference.html#bed_screws) (**à ajouter dans le printer.cfg**) permet
d'utiliser un Gcode étendu `BED_SCREWS_ADJUST`
```
## Mesh tools
[bed_screws]
# plateau de 330 x330
# vis fixation 37 mm de chaque bord
screw1: 37,37
screw1_name: AvantGauche
screw2: 293,37
screw2_name: AvantDroite
screw3: 293,293
screw3_name: ArriereDroite
screw4: 37,293
screw4_name: ArriereGauche
```

La [section suivante](https://www.klipper3d.org/fr/Config_Reference.html#screws_tilt_adjust) (**à ajouter dans le printer.cfg**) permet
d'utiliser la sonde pour indiquer les réglages à faire afin de niveler le plateau via un Gcode étendu `SCREWS_TILT_CALCULATE`
[screws_tilt_adjust]
# BLT (à droite/devant la buse : 28 / 4,4 )
# x=> -28, y=> +4.4
screw1: 9,41.4
screw1_name: AvantGauche
screw2: 265,41.4
screw2_name: AvantDroite
screw3: 265,297.4
screw3_name: ArriereDroite
screw4: 9,297.4
screw4_name: ArriereGauche
horizontal_move_z: 10
speed: 150
screw_thread: CW-M4
```

