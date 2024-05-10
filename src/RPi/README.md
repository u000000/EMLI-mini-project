Setup log using rsyslog in /etc/rsyslog.conf
```bash
#add rule for facility local7
local7.*    /var/www/html/log.log
```