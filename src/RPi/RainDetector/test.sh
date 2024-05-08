#!/bin/bash

# Open file descriptor 3 for reading from the serial port
exec 3< /dev/ttyACM0

while ! read -t 1 -u 3; do
    continue
done

# Read only one line using cat and head
line=$(cat <&3 | head -n 1)

# Close the file descriptor
exec 3<&-

# Display the line
echo $line

if [[ $line == *"\"rain_detect\": 0"* ]]; then
    echo "tak"
fi