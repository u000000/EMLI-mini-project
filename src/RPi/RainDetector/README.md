The scripts needs to be run. Pico is connected via USB, it's always ACM0 - changed to pico_01 to always have the correct one.

RPi first reads data coming via mqtt from rainDetectorLogic.sh. It is done creating a temporary file called "task". Every new line coming via mqtt is storred there and then it's used and sent via serial_port. The data is the wiper angle.
Mosquitto_sub runs in the background. It can't be a "single message" reader. If you start it, it will just work so the "task" file is a workaround to be able to get only one message and continue with the code.

Next the RPi waits for the data from serial port. If it comes, the "rain_detect" part is checked. If it equals 1, then the message RAINING is published via mqtt.

In the logic script we only check the mqtt data about the raining. If it rains we publish 180, 0 for the wiper.