# davical
Docker file for a complete davical server (davical + apache + postgresql) on Alpine Linux.
This simple repository contains a Dockerfile (and other configuration files) necessary to create an Alpine Linux image contains Davical + Apache + Postgresql server.

Davical is downloaded directly from its git repository while apache and postgres are installed from alpine linux repository.

### Settings
- Exposed Ports: TCP 80 and TCP 443
- Exposed Volumes: /config and /var/lib/postgresql/data/
- Exposed Variables: TIME_ZONE and HOST_NAME

On TCP 80 the web server listens with davical on hostname davical.example (set your local host file to point davical.example to 127.0.0.1)

Exposed environment variables can be overwritten when creating the docker container (eg. docke run -e HOST_NAME='example.com').
TIME_ZONE is set by default to "Europe/Rome" but you can set as you prefer according to tzdata (for example to "Europe/Paris" or "Europe/London")
HOST_NAME is set by default to "davical.example" 

/config can be mount and must contain a personalized version of all configuration files necessary:

- apache.conf
- davical.php 
- rsyslog.conf
- supervisord.conf

So you can download the configuration files present in this repository, alter and copy them into a directory to be mounted on /config and the container using them!
To use HTTPS on TCP port 433, you need to uncomment the related lines in apache.conf and provide a SSL certificate for your domain in /config.

/var/lib/postgresql/data contains the database and the directory backups/. In this directory crond every day saves (thanks to /sbin/backup_db) a dump of davical database to backups/davical_backup.tar
It is possible to restore the database using a backup: puit the backup into the mounted /config, run the container and after the initialization use "docker exec container_name /sbin/restore_db"

The rsyslog server is configured to collect all logs from apache and postgres into /var/log/messages but you can personalize the configuration altering rsyslog.conf and put it in /config. rsyslog does NOT collect apache access.log (it is disabled)

The default admin user is: admin with password: 12345 (you can alter it from the davical gui).

### Docker example
```
docker run -d --name davical -p 8080:80 -p 8443:443 -v /var/davical/config:/config -v /var/davical/data:/var/lib/postgresql/data -e HOST_NAME='my.example.com' -e TIME_ZONE='Europe/Berlin' mydavical
```
Creates and runs a davical Docker container which will be accessible on the host system on TCP ports 8080 and 8443 (HTTPS).
The config files must be created in /var/davical/config and the database file will be placed in /var/davical/data.
The time zone is set to Europe/berlin and the hostname is my.example.com.

### Credits
Based on https://github.com/IridiumXOR/davical and https://hub.docker.com/r/oliveria/davical (no HTTPS, older PG and PHP versions).
