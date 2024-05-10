#!/bin/bash

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
            json_data="{\"wiper_angle\": \"$mqqt_data\"}"
            

            mosquitto_pub -u emli -P raspberry -h localhost -p 1883 -t sometopic -m "2: $json_data"
            echo $json_data >&3
    fi
    
    while ! read -t 1 -u 3; do
        continue
    done
    serial_data=$(cat <&3 | head -n 1)
    mosquitto_pub -u emli -P raspberry -h localhost -p 1883 -t sometopic -m "1: $serial_data"
    if [[ $serial_data == *"\"rain_detect\": 1"* ]]; then
        mosquitto_pub -u emli -P raspberry -h localhost -p 1883 -t rain_detector_topic -m RAINING
    fi
done

function ctrl_c() {
    exec 3>&-
    kill %1
    exit 0
}

trap ctrl_c INT