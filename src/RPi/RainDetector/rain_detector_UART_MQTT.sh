#!/bin/bash

currently_raining=false
serial_port="/dev/ttyACM0"

exec 3<> "$serial_port"

mosquitto_sub -u emli -P raspberry -h localhost -p 1883 -t wiper_angle_topic > task &

NUMOFLINES=$(wc -l < task)
while :
do
    NEWLINE=$(wc -l < task)

    if [ "$NEWLINE" -gt "$NUMOFLINES" ]
    then
            NUMOFLINES=$(wc -l < task)
            mqqt_data=$(tail -n 1 task)
            json_data="{\"wiper_angle\": $mqqt_data}"
            mosquitto_pub -u emli -P raspberry -h localhost -p 1883 -t serial_connection -m "$json_data"
            echo $json_data >&3
    fi
    
    serial_data=$(cat <&3 | head -n 2 | tail -n 1)
    # if serial connection does not contain "json error" publish the data to the MQTT broker
    if [[ $serial_data != *"json_error"* ]]; then
        mosquitto_pub -u emli -P raspberry -h localhost -p 1883 -t serial_connection -m "$serial_data"
        if [[ $serial_data == *"\"rain_detect\": 1"* ]]; then
            if [ "$currently_raining" = false ]; then
                currently_raining=true
                logger -p local7.info -t rain_detect "Started raining"
            fi
            mosquitto_pub -u emli -P raspberry -h localhost -p 1883 -t rain_detector_topic -m RAINING
        elif [[ $serial_data == *"\"rain_detect\": 0"* ]]; then
            if [ "$currently_raining" = true ]; then
                currently_raining=false
                logger -p local7.info -t rain_detect "Stopped raining"
            fi
        fi
    fi

done

function ctrl_c() {
    exec 3>&-
    kill %1
    exit 0
}

trap ctrl_c INT