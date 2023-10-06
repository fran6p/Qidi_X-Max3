#!/bin/bash
#
# Backup csv file as they are deleted when printer is powered off (/tmp directory is emptied at poweroff)
#

# Paths
CSV_FILE="/tmp/calibration_data_*.csv"
DIR_CONF="/home/mks/klipper_config/calibrations"

cp $CSV_FILE $DIR_CONF