Il est possible d'afficher les températures du contrôleur Rockchip (RK3328) ainsi que celle du microcontrôleur (MCU) de la carte de l'imprimante 
=> voir [ici](https://www.klipper3d.org/fr/Config_Reference.html#capteur-de-temperature-integre-au-microcontroleur) )

Ajouter dans le printer.cfg :
```
#==================  Temperatures host + μcontroler =================
[temperature_sensor RK3328]
sensor_type: temperature_host
min_temp: 10
max_temp: 75

[temperature_sensor STM32F402]
sensor_type: temperature_mcu
min_temp: 10
max_temp: 75
```

Ce qui donne :

![températures Mainsail](../Images/mainsail-températures.jpg)
