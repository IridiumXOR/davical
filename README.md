# DAViCal Docker Container
Docker image for a complete [DAViCal](https://www.davical.org/) server (DAViCal + Apache2 + PostgreSQL) on Alpine Linux.
The repository on github.org contains example configuration files for DAViCal (as well as the Dockerfile to create the Docker image).

### About DAViCal
[DAViCal](https://www.davical.org/) is a server for shared calendars. It implements the [CalDAV protocol](https://wikipedia.org/wiki/CalDAV) and stores calendars in the [iCalendar format](https://wikipedia.org/wiki/ICalendar).

List of supported clients: Mozilla Thunderbird/Lightning, Evolution, Mulberry, Chandler, iCal, ...

**Features**
>    - DAViCal is Free Software licensed under the General Public License.
>    - uses an SQL database for storage of event data
>    - supports backward-compatible access via WebDAV in read-only or read-write mode (not recommended)
>    - is committed to inter-operation with the widest possible CalDAV client software.
>
>DAViCal supports basic delegation of read/write access among calendar users, multiple users or clients reading and writing the same calendar entries over time, and scheduling of meetings with free/busy time displayed.
(*https://www.davical.org/*)

### Settings
- Exposed Ports: TCP 80 and TCP 443
- Exposed Volumes: /config and /var/lib/postgresql/data/
- Exposed Variables: TIME_ZONE and HOST_NAME

On TCP 80 the web server listens with DAViCal on hostname davical.example (set your local host file to point davical.example to 127.0.0.1)

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

/var/lib/postgresql/data contains the database and the directory backups/. In this directory crond every day saves (thanks to /sbin/backup_db) a dump of DAViCal database to backups/davical_backup.tar
It is possible to restore the database using a backup: put the backup into the mounted /config, run the container and after the initialization use "docker exec container_name /sbin/restore_db"

The rsyslog server is configured to collect all logs from apache and postgres into /var/log/messages but you can personalize the configuration altering rsyslog.conf and put it in /config. rsyslog does NOT collect apache access.log (it is disabled)

The **default admin user** is: *admin* with password: *12345* (you can alter it from the DAViCal gui).

### Docker examples

**Simple test**
```
docker run -d --name davical-test -p 8080:80 datze/davical_https
```
Creates and runs a DAViCal Docker container which is fully operable on host TCP port 8080. Does not require any further configuration. *Attention! Only for testing! When the container is deleted, all stored calendars are lost!*

**Simple HTTP mode**
```
docker run -d --name davical -p 8080:80 -v var/davical/data:/var/lib/postgresql/data datze/davical_https
```
Creates and runs a DAViCal Docker container with default configurations on host TCP port 8080. The **database files are stored in /var/davical/data**. This is the simplest set-up without loosing calendars when the container is deleted.

**Full example**
```
docker run -d --name davical -p 8080:80 -p 8443:443 -v /var/davical/config:/config -v /var/davical/data:/var/lib/postgresql/data -e HOST_NAME='my.example.com' -e TIME_ZONE='Europe/Berlin' datze/davical_https
```
Creates and runs a DAViCal Docker container which will be accessible on the host system on TCP ports 8080 and 8443 (HTTPS).
The time zone is set to Europe/Berlin and the hostname is my.example.com.

The **config files must be created in /var/davical/config** and the **database files are stored in /var/davical/data**.

A SSL certificate must be placed in /var/davical/config and referenced in /var/davical/config/apache.conf. (Create a self-signed certificate with something like `openssl req -x509 -newkey rsa:4096 -keyout /var/davical/config/ssl/private.pem -out /var/davical/config/ssl/cert.pem -days 1000`)

### Credits
Based on https://github.com/IridiumXOR/davical and https://hub.docker.com/r/oliveria/davical (no HTTPS, older PG and PHP versions).
