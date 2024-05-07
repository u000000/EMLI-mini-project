#!/bin/bash

while true; do

    macToIgnore="bc:ff:4d:40:9e:49"
    #see if any others in sudo iw dev wlan0 station dump | grep Station
    macs=$(iw dev wlan0 station dump | grep Station | awk '{print $2}')
    
    macDroneFound=""
    ipOfDrone=""
    for mac in $macs; do
        if [ "$mac" != "$macToIgnore" ]; then
            macDroneFound=$mac
            break
        fi
    done

    #check if no mac was found
    if [ -z "$macDroneFound" ]; then
        echo "No drone found"
        sleep 1
        continue
    fi

    ipOfDrone=$(arp -n | grep $macDroneFound | awk '{print $1}')

    #set time from ntp server on drone
    ntpdate $ipOfDrone

    sleep 1
done

