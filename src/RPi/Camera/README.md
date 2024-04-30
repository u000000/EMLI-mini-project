For time we have added to /etc/crontab :
```bash
#Run every five minute
*/5  * * * * emli /home/emli/EMLI-mini-project/src/RPi/Camera/take_photo.sh Time 
```