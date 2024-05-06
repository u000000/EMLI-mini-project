#!/bin/bash

#get string parameter
TRIGGER=${1:-"External"}
SAVEPATH=${2:-"/home/emli/webcam/"}

echo "Taking photo..."

# timestamp for the new file
MS=$(date +"%3N")
DATE_STRING=$(date)

DATE=$(date -d "$DATE_STRING" +"%Y-%m-%d")

#check if $2 is default or not
if [ "$SAVEPATH" == "/home/emli/webcam-temp/" ]; then
  FOLDER="/home/emli/webcam-temp/"
else
  FOLDER="$SAVEPATH$DATE/"
fi

#make the directory called $DATE
mkdir -p $FOLDER

#timestap
TIMESTAMP=$(date -d "$DATE_STRING"  +"%H%M%S_$MS")

# the output path + filename
IMAGENAME="$TIMESTAMP"

IMAGETYPE=".jpg"
SIDECARTYPE=".json"
# the size of the screenshot to take
rpicam-jpeg -o $FOLDER$IMAGENAME$IMAGETYPE --width 640 --height 480 -t 1

echo "Saved new file at $FOLDER$IMAGENAME$IMAGETYPE"

#Date for timestamped json "2021-09-01 13:42:24.033+02:00"
TIMESTAMP_JSON=$(date -d "$DATE_STRING"  +"%Y-%m-%d %H:%M:%S.$MS%:z")
#Time since epoc
TIMESTAMP_EPOC=$(date -d "$DATE_STRING"  +"%s.$MS")

DISTANCE=$(exiftool -SubjectDistance $FOLDER$IMAGENAME$IMAGETYPE | awk '{print $4}')
EXPOSURETIME=$(exiftool -ExposureTime $FOLDER$IMAGENAME$IMAGETYPE | awk '{print $4}')
ISO=$(exiftool -ISO $FOLDER$IMAGENAME$IMAGETYPE | awk '{print $3}')

#Make a json
echo "Creating JSON..."
echo "{" > $FOLDER$IMAGENAME$SIDECARTYPE
echo "  \"File Name\": \"$IMAGENAME$IMAGETYPE\"," >> $FOLDER$IMAGENAME$SIDECARTYPE
echo "  \"Create Date\": \"$TIMESTAMP_JSON\"," >> $FOLDER$IMAGENAME$SIDECARTYPE
echo "  \"Create Seconds Epoch\": $TIMESTAMP_EPOC," >> $FOLDER$IMAGENAME$SIDECARTYPE
echo "  \"Trigger\": \"$TRIGGER\"," >> $FOLDER$IMAGENAME$SIDECARTYPE
echo "  \"Subject Distance\": $DISTANCE," >> $FOLDER$IMAGENAME$SIDECARTYPE
echo "  \"Exposure Time\": \"$EXPOSURETIME\"," >> $FOLDER$IMAGENAME$SIDECARTYPE
echo "  \"ISO\": $ISO" >> $FOLDER$IMAGENAME$SIDECARTYPE
echo "}" >> $FOLDER$IMAGENAME$SIDECARTYPE

echo "✔ Complete!"

exit 0