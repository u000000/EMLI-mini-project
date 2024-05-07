#!/bin/bash

mosquitto_sub -u emli -P raspberry -h localhost -p 1883 -t rain_detector_topic | while read -r mqtt_data
do
    if [[ $mqtt_data == 'RAINING' ]]; then
        mosquitto_pub -u emli -P raspberry -h localhost -p 1883 -t wiper_angle_topic -m "0"
        sleep 0.5
        mosquitto_pub -u emli -P raspberry -h localhost -p 1883 -t wiper_angle_topic -m "180"
        sleep 0.5
        mosquitto_pub -u emli -P raspberry -h localhost -p 1883 -t wiper_angle_topic -m "0"
    fi
done