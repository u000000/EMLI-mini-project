setup of mysql database
```bash
    sudo apt update
    sudo apt install mysql-server
    sudo systemctl start mysql.service
```
```sql
CREATE DATABASE emli_wifi_quality;

USE emli_wifi_quality;

CREATE TABLE wifi_signal (
    wifi_linkquality INT,
    signal_level  INT,
    epoch_time INT
);
```

setup the service to save link quality in mysql database.
```bash
sudo ln -s /home/drone/EMLI-mini-project/src/RPi/Drone/saveLinkQualityToWildCam.service /etc/systemd/system/saveLinkQualityToWildCam.service 

sudo systemctl start saveLinkQualityToWildCam

sudo systemctl enable saveLinkQualityToWildCam
```
