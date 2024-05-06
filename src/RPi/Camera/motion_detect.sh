#!/bin/bash

# Set the path to the directory where the images will be stored
directory="/home/emli/webcam-temp/"

rm -rf $directory
mkdir -p $directory

# every second take picture

image1=""
image2=""
firstimage=true
while true
do
    # take a picture
    /home/emli/EMLI-mini-project/src/RPi/Camera/take_photo.sh Motion $directory

    

    if [ "$firstimage" = true ]; then
        firstimage=false
        continue
    else
        #read jpg files sorted by date newest first
        jpeg_files=$(ls $directory | grep .jpg | sort -r)
        
        #first image
        image1=$directory$(echo $jpeg_files | awk '{print $1}')
        image2=$directory$(echo $jpeg_files | awk '{print $2}')
        
        # compare the last two images using python3 motion_detect.py
        output=$(python3 /home/emli/EMLI-mini-project/src/RPi/Camera/motion_detect.py $image1 $image2)
        
        json2=${image2::-4}".json"
        rm $image2
        rm $json2

        # if the output is "Motion detected"
        if [ "$output" == "Motion detected" ]; then
            #get corresponding json
            json1=${image1::-4}".json"
            #from json read the Create Date
            create_date=$(cat $json1 | grep "Create Date" | awk '{print $3}' | sed 's/\"//g')
            cp $image1 /home/emli/webcam/$create_date
            cp $json1 /home/emli/webcam/$create_date

        fi
    
    fi
    # wait for 1 second
    sleep 1
done


