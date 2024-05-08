#!/bin/bash

droneSymLinkDirectory="/home/emli/webcam/"
logSymLinkDirectory="/home/emli/webcam_log/"

while true; do
    echo "Waiting for new files to be deleted..."
    deleted_file=$(inotifywait -q -e delete -r --format '%w%f' "$droneSymLinkDirectory")

    #diff= Only in /home/emli/webcam_log/2024-04-01: 135741_640.json
    #so making sure it is only in log directory
    difference=$(diff -r "$droneSymLinkDirectory" "$logSymLinkDirectory" 2>&1)
    if [ $? -ne 0 ]; then
        echo "Error: $difference"
        continue
    fi
    difference=$(echo "$difference" | grep "Only" | grep "$logSymLinkDirectory" | awk -F'/' '{print "/"$2"/"$3"/"$4"/ "$5}' | sed 's/:/ /g')
    echo "Difference: $difference"

    num_lines=$(echo "$difference" | wc -l)
    if [ "$num_lines" -lt 2 ]; then
        echo "Less than 2 lines, continuing..."
        continue
    fi

    files=$(echo $difference | awk  '{print $3}')
    echo "Files: $files"

    #delete the .jpg and .json
    files=$(echo "$files" | sed -e 's/\.json//g' -e 's/\.jpg//g')
    echo "Files: $files"

    #get the duplicate files
    duplicatefiles=$(echo $files | uniq -D | uniq)
    echo "Duplicate files: $duplicatefiles"

    timestamp=$(date +"%s.%3N")

    for file in $duplicatefiles; do
        echo "Updating $file.json..."
        # Define JSON file path
        date=date=$(echo $difference | grep $file | awk  '{print $2}' | head -n 1)
        json_file="$droneSymLinkDirectory$date/$file.json"
        echo "JSON file: $json_file"

        # get last digits of ip 
        droneID=$(bash /home/emli/EMLI-mini-project/src/RPi/Networking/get_drone_ip.sh | awk -F'.' '{print $4}')
        echo "Drone ID: $droneID"
        # Define the data to add
        drone_copy="{\"Drone Copy\": {\"Drone ID\": \"WILDDRONE-$droneID\", \"Seconds Epoch\": $timestamp}}"
        echo "Drone Copy: $drone_copy"
        # Update the JSON file using jq
        jq -s '.[0] * .[1]' <(echo "$drone_copy") "$json_file" > temp.json && mv temp.json "$json_file"

        echo "Updated $file.json"
        cat $json_file

    done


done
exit 0
