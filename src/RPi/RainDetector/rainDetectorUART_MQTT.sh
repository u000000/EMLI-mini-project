#!/bin/bash

trap ctrl_c INT
serial_port="/dev/ttyACM0"
baud_rate="115200"

exec 3<> "$serial_port"
stty -F "$serial_port" "$baud_rate"

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
            echo "$json_data" >&3
    fi

    serial_data=$(screen serial_port baud_rate)
    if [[ $(echo "$serial_data" | jq -r '.rain_detect') == "1" ]]; then
        mosquitto_pub -u emli -P raspberry -h localhost -p 1883 -t rain_detector_topic -m RAINING
    fi
done

function ctrl_c() {
    exec 3>&-
    kill %1
    exit 0
}