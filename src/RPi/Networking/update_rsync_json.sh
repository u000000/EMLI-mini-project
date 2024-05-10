#!/bin/bash

droneSymLinkDirectory="/home/emli/webcam/"
logSymLinkDirectory="/home/emli/webcam_log/"

droneID=""

while true; do
    #Outcomment because might miss last files while writing other json files
    #deleted_file=$(inotifywait -q -e delete -r --format '%w%f' "$droneSymLinkDirectory")

    #diff= Only in /home/emli/webcam_log/2024-04-01: 135741_640.json
    #so making sure it is only in log directory
    difference=$(diff -r "$droneSymLinkDirectory" "$logSymLinkDirectory")
    difference=$(echo "$difference" | grep "Only in $logSymLinkDirectory")

    num_lines=$(echo "$difference" | wc -l)
    if [ "$num_lines" -lt 2 ]; then
        sleep 1
        continue
    fi
    echo "Found 2 or more files, we can now have sent both a json and a jpeg"

    #get the duplicate files
    duplicateDifference=$(echo "$difference" | sed -e 's/\Only in //g' -e 's/\.json//g' -e 's/\.jpg//g' -e 's/: /\//g' | uniq -D | uniq)

    timestamp=$(date +"%s.%3N")

    for file in $duplicateDifference; do
        echo "Updating $file.json..."
        # Define JSON file path
        #replace the logSymLinkDirectory with /var/www/html/image/
        json_file=$(echo "$file.json" | sed -e "s#$logSymLinkDirectory#/var/www/html/images/#g")

        # get last digits of ip 
        droneIP=$(bash /home/emli/EMLI-mini-project/src/RPi/Networking/get_drone_ip.sh)
        #check if valid ip or "No drone found"
        if [ "$droneIP" != "No drone found" ]; then
            droneID=$(echo $droneIP | awk -F'.' '{print $4}')
        fi

        # Define the data to add
        drone_copy="{\"Drone Copy\": {\"Drone ID\": \"WILDDRONE-$droneID\", \"Seconds Epoch\": $timestamp}}"
        # Update the JSON file using jq
        jq -s '.[0] * .[1]' <(echo "$drone_copy") "$json_file" > temp.json && mv temp.json "$json_file"

        rm "$file.jpg"
        rm "$file.json"

        logger -p local7.info -t transfer_files "Updated $json_file with $drone_copy."

    done

    sleep 1

done
exit 0
