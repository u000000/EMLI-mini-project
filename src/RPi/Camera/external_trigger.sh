#!/bin/bash

#subscribe to mosquitto
mosquitto_sub -h localhost -u emli -P raspberry -t "emli/trigger/pressure_plate" | while read TRIGGER
# if message is triggered then take a picture
do
  if [ "$TRIGGER" == "triggered" ]; then
    echo "triggered"
    #take a picture
    /home/emli/EMLI-mini-project/src/RPi/Camera/take_photo.sh External /var/www/html/images/ true /home/emli/webcam/
  fi
done