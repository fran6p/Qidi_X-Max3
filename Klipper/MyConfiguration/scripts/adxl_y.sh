#!/usr/bin/bash
#
# Create PNG from csv file issued after INPUT_SHAPING, Y axis
#

# Paths
#
DATE=$(date +"%Y%m%d")
SCRIPTS="~/klipper/scripts/calibrate_shaper.py"
CSV_FILE="/tmp/calibration_data_y_*.csv"
PNG_FILE="~/klipper_config/calibrations/shaper_calibrate_y_$DATE.png"

$SCRIPTS $CSV_FILE -o $PNG_FILE