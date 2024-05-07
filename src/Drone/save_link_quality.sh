#!/bin/bash

# Define MySQL connection parameters
MYSQL_HOST="localhost"
MYSQL_USER="root"
MYSQL_PASSWORD="password"
MYSQL_DATABASE="emli_wifi_quality"
MYSQL_TABLE="wifi_signal"

while true; do

    #check cat /proc/net/wireless to see if there is a present connection
    connectionUp=$(cat /proc/net/wireless | grep wlo1)
    if [ -z "$connectionUp" ]; then
        echo "No connection"
        sleep 1
        continue
    fi

    link_quality=$(cat /proc/net/wireless | grep wlo1 | awk '{print $3}' | cut -d '.' -f1)
    signal_level=$(cat /proc/net/wireless | grep wlo1 | awk '{print $4}' | cut -d '.' -f1)
    time_epoch=$(date +%s)
    echo "('$link_quality', '$signal_level', '$time_epoch')"

    mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" \
        -e "INSERT INTO $MYSQL_TABLE (wifi_linkquality, signal_level, epoch_time) VALUES ('$link_quality', '$signal_level', '$time_epoch');"

    sleep 1
done