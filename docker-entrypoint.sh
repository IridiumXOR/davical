#!/bin/bash

#SET THE TIMEZONE
apk add --update tzdata
cp /usr/share/zoneinfo/$TIME_ZONE /etc/localtime
echo $TIME_ZONE > /etc/timezone
apk del tzdata

#PREPARE THE PERMISSIONS FOR VOLUMES
mkdir 	/config
chown -R root:root /config
chmod -R 755 /config
mv -n 	/apache.conf /config/apache.conf
mv -n	/davical.php /config/davical.php
mv -n	/supervisord.conf /config/supervisord.conf
mv -n	/rsyslog.conf /config/rsyslog.conf
chown -R root:root /config
chmod -R 755 /config
chown root:apache /config/davical.php
chmod u+rwx,g+rx /config/davical.php

#SET THE DATABASE ONLY AT THE FIRST RUN
chown -R postgres:postgres /var/lib/postgresql
if [ ! -e /var/lib/postgresql/data/pg_hba.conf ]; then
	su - postgres -c "initdb -D data"
	echo "listen_addresses='*'" >> /var/lib/postgresql/data/postgresql.conf
	echo "log_destination = 'syslog'" >> /var/lib/postgresql/data/postgresql.conf
	echo "syslog_facility = 'LOCAL1'" >> /var/lib/postgresql/data/postgresql.conf
	echo "timezone = $TIME_ZONE" >> /var/lib/postgresql/data/postgresql.conf
	sed -i "/# Put your actual configuration here/a local   davical    davical_app   trust\nlocal   davical    davical_dba   trust" /var/lib/postgresql/data/pg_hba.conf
	mkdir /var/lib/postgresql/data/backups
	chown -R postgres:postgres /var/lib/postgresql/data/backups
fi

#LAUNCH THE INIT PROCESS
exec /usr/bin/supervisord

