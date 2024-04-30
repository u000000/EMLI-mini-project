#!/bin/bash



echo "Taking photo..."

# timestamp for the new file
DATE_STRING=$(date)

DATE=$(date -d "$DATE_STRING" +"%Y-%m-%d")

FOLDER="/home/emli/webcam/$DATE/"

#make the directory called $DATE
mkdir -p $FOLDER

#timestap
TIMESTAMP=$(date -d "$DATE_STRING"  +"%H%M%S_%3N")

# the output path + filename
IMAGENAME="$TIMESTAMP"

IMAGETYPE=".jpg"
SIDECARTYPE=".json"
# the size of the screenshot to take
rpicam-jpeg -o $FOLDER$IMAGENAME$IMAGETYPE --width 640 --height 480 -t 1

echo "Saved new file at $FOLDER$IMAGENAME$IMAGETYPE"

#Date for timestamped json "2021-09-01 13:42:24.033+02:00"
TIMESTAMP_JSON=$(date -d "$DATE_STRING"  +"%Y-%m-%d %H:%M:%S.%3N%:z")
#Time since epoc
TIMESTAMP_EPOC=$(date -d "$DATE_STRING"  +"%s.%3N")

#Make a json
echo "Creating JSON..."
echo "{" > $FOLDER$IMAGENAME$SIDECARTYPE
#"File Name": "134224_033.jpg"
echo "  \"File Name\": \"$IMAGENAME$IMAGETYPE\"," >> $FOLDER$IMAGENAME$SIDECARTYPE
#"Create Date": "2021-09-01 13:42:24.033+02:00",
echo "  \"Create Date\": \"TIMESTAMP_JSON\"," >> $FOLDER$IMAGENAME$SIDECARTYPE
#"Create Seconds Epoch": "123123321",
echo "  \"Create Seconds Epoch\": \"$TIMESTAMP_EPOC\"," >> $FOLDER$IMAGENAME$SIDECARTYPE


#echo "Starting rsync..."

# src is the local folder with all the images
#SRC="/home/pi/webcam/images/"

# destination location on the remote server
#DEST="user@somedomain.com:/var/www/html/website/webcam/images/"

# the command to use to move the files
#rsync --update --archive --delete --recursive --compress --progress --chown=www-data:www-data --chmod=u=rwx,g=rx,o=rx $SRC $DEST

echo "✔ Complete!"

exit 0