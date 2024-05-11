#!/bin/bash

#get string parameter
TRIGGER=${1:-"External"}
SAVEPATH=${2:-"/var/www/html/images/"}
SUBFOLDERDATE=${3:-true}
SYMLINK=${4:-""}
SYMLINKLOG=${5:-""}

echo "Taking photo..."

# timestamp for the new file
MS=$(date +"%3N")
DATE_STRING=$(date)

DATE=$(date -d "$DATE_STRING" +"%Y-%m-%d")

#check if $3 is true
if [ "$SUBFOLDERDATE" == true ]; then
  FOLDER="$SAVEPATH$DATE/"

  #add $DATE to symlink if it is not empty and $3 is true
  if [ ! -z "$SYMLINK" ]; then
    SYMLINK="$SYMLINK$DATE/"
  fi

  #add $DATE to symlink if it is not empty and $3 is true
  if [ ! -z "$SYMLINKLOG" ]; then
    SYMLINKLOG="$SYMLINKLOG$DATE/"
  fi
else
  FOLDER="$SAVEPATH"
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
#check if the exit status of last command is not 0
if [ $? -ne 0 ]; then
  #dont log if trigger is Motion
  if [ "$TRIGGER" != "Motion" ]; then
    logger -p local7.info -t take_photo "Trigger: $TRIGGER could not aquire camera image."
  fi
  echo "Could not acquire camera image. Exiting..."
  exit 1
fi

echo "Saved new file at $FOLDER$IMAGENAME$IMAGETYPE"
if [ "$TRIGGER" != "Motion" ]; then
  logger -p local7.info -t take_photo "Trigger: $TRIGGER saved to $FOLDER$IMAGENAME.*"
fi


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
  mkdir -p $SYMLINKLOG
  ln -s $FOLDER$IMAGENAME$IMAGETYPE $SYMLINKLOG$IMAGENAME$IMAGETYPE
  ln -s $FOLDER$IMAGENAME$SIDECARTYPE $SYMLINKLOG$IMAGENAME$SIDECARTYPE
  echo "Created symbolic link at $SYMLINK$IMAGENAME$IMAGETYPE"
  echo "Created symbolic link at $SYMLINKLOG$IMAGENAME$IMAGETYPE"
fi

exit 0