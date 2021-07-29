#!/bin/sh

# This file is a shell script that can convert the h5 file into json file that can use in C++.
# You can change the file address as you want.

scriptdir="$(dirname "$0")"
cd "$scriptdir"

CONVERT_MODEL_FILE_ADDRESS="../keras_to_C++/frugally-deep/keras_export/convert_model.py"    # "convert_model.py" is always in folder "frugally-deep/keras_export/". This python file mainly convert the file
H5_FILE_ADDRESS="./sql_injection_detecting.h5"            # this variable is the address where your .h5 file is.
JSON_FILE_ADDRESS="./sql_injection_detecting.json"     # this variable is the address where you want the json file be.

python3 $CONVERT_MODEL_FILE_ADDRESS $H5_FILE_ADDRESS $JSON_FILE_ADDRESS
echo "\e[92mconvert into json file success!\033[0m"