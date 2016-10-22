# davical
Docker file for a complete davical server (davical + apache + postgresql) on Alpine Linux

This simple repository contains a Dockerfile (and other configuration files) necessary to create an Alpine Linux image contains Davical + Apache + Postgresql server

Davical is downloaded directly from its git repository while apache and postgres are installed from alpine linux repository.


-> Exposed Ports: TCP 80

-> Exposed Volumes: /config, /var/lib/postgresql/data/

-> Exposed Variables: TIME_ZONE


On TCP 80 is listening apache server with davical on hostname davical.example (set your local host file to point davical.example to 127.0.0.1)

TIME_ZONE is set by default to "Europe/Rome" but you can set as you prefer according to tzdata (for example to "Europe/Paris" or "Europe/London")

/config can be mount and must contains a personalized version of all configuration files necessary:

->apache.conf

->davical.php 

->rsyslog.conf

->supervisord.conf

So you can download the configuration files present in this repository, alter and copy them into /config
and mount it, the container using it!

/var/lib/postgresql/data contains the database and the directory backups/. In this directory crond every day saves (thanks to /sbin/backup_db) a dump of davical database to backups/davical_backup.tar
It is possible to restore the database using a backup putting it in /config and run after the init /sbin/restore_db

The rsyslog server is configured to collect all logs from apache and postgres into /var/log/messages but you can personalize the configuration
altering rsyslog.conf and put it in /config. rsyslog do NOT collect apache access.log (it is disabled)

The init system used is supervisord with some fixes necessary due to a bug...
