#!/bin/sh

set -e

# create python env
python -m venv env

# activate the python env instead of the os version of python
. env/bin/activate

# install required packages
python3 -m pip install -r requirements.txt

# get the list of Discord commands to register and proceed
JSON_FILES_PATH="./commands/*.json"
echo "Register commands from $JSON_FILES_PATH"
for f in $JSON_FILES_PATH
do
    echo "Processing $f..."
    python ./register-cmd.py "$f"
done

# leave the virtual environment
deactivate

# delete the virtual environment
rm -rf env
