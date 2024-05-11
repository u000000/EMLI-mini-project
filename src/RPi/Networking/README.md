For running the check connection and update the time script as a service on boot added symbolic link to /etc/systemd/system/updateTimeFromDrone.service
```bash
sudo ln -s /home/emli/EMLI-mini-project/src/RPi/Networking/updateTimeFromDrone.service /etc/systemd/system/updateTimeFromDrone.service 

sudo systemctl start updateTimeFromDrone

sudo systemctl enable updateTimeFromDrone
```

same for writing to jsons whhen rsynced
```bash
sudo ln -s /home/emli/EMLI-mini-project/src/RPi/Networking/updateJsonOfTransferedFiles.service /etc/systemd/system/updateJsonOfTransferedFiles.service

sudo systemctl start updateJsonOfTransferedFiles

sudo systemctl enable updateJsonOfTransferedFiles
```