#!/bin/bash

# Set the path to the directory where the images will be stored
directory="/home/emli/webcam-temp/"
symlinkdir=${1:-"/home/emli/webcam/"}
symlinklogdir=${2:-"/home/emli/webcam_log/"}

rm -rf $directory
mkdir -p $directory

# every second take picture

image1=""
image2=""
firstimage=true
while true
do
    # take a picture
    /home/emli/EMLI-mini-project/src/RPi/Camera/take_photo.sh Motion $directory false

    if [ "$firstimage" = true ]; then
        firstimage=false
        sleep 3
        continue
    else
        #read jpg files sorted by date newest first
        jpeg_files=$(ls $directory | grep .jpg | sort -r)
        
        #first image
        image1=$(echo $jpeg_files | awk '{print $1}')
        image2=$(echo $jpeg_files | awk '{print $2}')
        dirimage1=$directory$image1
        dirimage2=$directory$image2
        # compare the last two images using python3 motion_detect.py
        output=$(python3 /home/emli/EMLI-mini-project/src/RPi/Camera/motion_detect.py $dirimage1 $dirimage2)
        
        dirjson2=${dirimage2::-4}".json"
        rm $dirimage2
        rm $dirjson2

        # if the output is "Motion detected"
        if [ "$output" == "Motion detected" ]; then
            echo "Motion detected"
            #get corresponding json
            json1=${image1::-4}".json"
            dirjson1=$directory$json1
            #from json read the Create Date
            create_date=$(cat $dirjson1 | grep "Create Date" | awk '{print $3}' | sed 's/\"//g')
            
            cp $dirimage1 /var/www/html/images/$create_date
            cp $dirjson1 /var/www/html/images/$create_date

            #make symlink from each copied files into /home/emli/webcam/
            mkdir -p $symlinkdir$create_date
            mkdir -p $symlinklogdir$create_date
            ln -s /var/www/html/images/$create_date/$image1 $symlinkdir$create_date
            ln -s /var/www/html/images/$create_date/$json1 $symlinkdir$create_date
            ln -s /var/www/html/images/$create_date/$image1 $symlinklogdir$create_date
            ln -s /var/www/html/images/$create_date/$json1 $symlinklogdir$create_date



        fi
    
    fi
    # wait for 1 second
    sleep 3
done


