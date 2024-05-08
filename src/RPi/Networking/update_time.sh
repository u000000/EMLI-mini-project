#!/bin/bash

while true; do

    ipOfDrone=$(bash /home/emli/EMLI-mini-project/src/RPi/Networking/get_drone_ip.sh)

    #if not "No drone found"
    if [ "$ipOfDrone" != "No drone found" ]; then
        #update the time
        ntpdate $ipOfDrone
    fi

    sleep 1
done

