#!/bin/bash
#
# Create PNG from csv file issued after INPUT_SHAPING, X axis
#

# Paths
# 
#
DATE=$(date +"%Y%m%d")
SCRIPTS="~/klipper/scripts/calibrate_shaper.py"
CSV_FILE="/tmp/calibration_data_x_*.csv"
PNG_FILE="~/klipper_config/calibrations/shaper_calibrate_x_$DATE.png"

python3 $SCRIPTS $CSV_FILE -o $PNG_FILE
