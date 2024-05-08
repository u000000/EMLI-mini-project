#!/bin/bash

#get string parameter
TRIGGER=${1:-"External"}
SAVEPATH=${2:-"/var/www/html/images/"}
SUBFOLDERDATE=${3:-true}
SYMLINK=${4:-""}

echo "Taking photo..."

# timestamp for the new file
MS=$(date +"%3N")
DATE_STRING=$(date)

DATE=$(date -d "$DATE_STRING" +"%Y-%m-%d")

#check if $3 is true
if [ "$SUBFOLDERDATE" == true ]; then
  FOLDER="$SAVEPATH$DATE/"
else
  FOLDER="$SAVEPATH"
fi

#add $DATE to symlink if it is not empty and $3 is true
if [ ! -z "$SYMLINK" ] && [ "$SUBFOLDERDATE" == true ]; then
  SYMLINK="$SYMLINK$DATE/"
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

#Make symbolic link if $4 is not empty
if [ ! -z "$SYMLINK" ]; then
  mkdir -p $SYMLINK
  ln -s $FOLDER$IMAGENAME$IMAGETYPE $SYMLINK$IMAGENAME$IMAGETYPE
  ln -s $FOLDER$IMAGENAME$SIDECARTYPE $SYMLINK$IMAGENAME$SIDECARTYPE
  echo "Created symbolic link at $SYMLINK$IMAGENAME$IMAGETYPE"
fi

exit 0