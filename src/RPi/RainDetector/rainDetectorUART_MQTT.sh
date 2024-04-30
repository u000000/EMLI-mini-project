#!/bin/bash

# Set the serial port and baud rate
serial_port="/dev/ttyACM0"
baud_rate="115200"

# Open the serial port
exec 3<> "$serial_port"
stty -F "$serial_port" "$baud_rate"

while true; do
    # Subscribe to MQTT topic
    if mosquitto_sub -u emli -P raspberry -h localhost -p 1883 -t wiper_angle_topic | while read -r mqtt_data; do
        # Check if data is received via MQTT
        if [[ $mqtt_data ]]; then
            # Create JSON object with 'wiper_angle' variable
            json_data=$(jq -n --arg angle "$mqtt_data" '{"wiper_angle": $angle}')

            # Send JSON object via serial port
            echo "$json_data" >&3
        else
            # Read data from the serial port
            while read -r line <&3; do
                echo "$line"

                if [[ $(echo "$line" | jq -r '.rain_detect') == "1" ]]; then
                    # Publish information via MQTT
                    mosquitto_pub -u emli -P raspberry -h localhost -p 1883 -t rain_detector_topic -m RAINING
                fi
            done
        fi
    done;
    else
        # Handle the case when mosquitto_sub fails
        echo "Failed to subscribe to MQTT topic"
    fi
done

# Close the serial port
exec 3>&-