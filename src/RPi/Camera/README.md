For time we have added to /etc/crontab :
```bash
#Run every five minute
*/5  * * * * emli /home/emli/EMLI-mini-project/src/RPi/Camera/take_photo.sh Time 
```

For running external trigger mqtt receive on boot added symbolic link to /etc/systemd/system/externaltrigger.service
```bash
sudo ln -s /home/emli/EMLI-mini-project/src/RPi/Camera/externalTrigger.service /etc/systemd/system/externalTrigger.service 

sudo systemctl start externalTrigger

sudo systemctl enable externalTrigger
```

