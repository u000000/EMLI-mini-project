For time we have added to /etc/crontab :
```bash
#Run every five minute
*/5  * * * * emli /home/emli/EMLI-mini-project/src/RPi/Camera/take_photo.sh Time /var/www/html/images/ true /home/emli/webcam/ /home/emli/webcam_log/
```

For running external trigger mqtt receive on boot added symbolic link to /etc/systemd/system/externaltrigger.service
```bash
sudo ln -s /home/emli/EMLI-mini-project/src/RPi/Camera/externalTrigger.service /etc/systemd/system/externalTrigger.service 

sudo systemctl start externalTrigger

sudo systemctl enable externalTrigger
```

same for motion detector
```bash
sudo ln -s /home/emli/EMLI-mini-project/src/RPi/Camera/motionDetector.service /etc/systemd/system/motionDetector.service 

sudo systemctl start motionDetector

sudo systemctl enable motionDetector
```

