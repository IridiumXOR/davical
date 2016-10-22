#!/bin/sh
su - postgres -c 'createdb --owner davical_dba --encoding UTF8 --template template0 davical'
su postgres -c 'pg_restore -Ft -d davical /config/davical_backup.tar'
/usr/share/davical/dba/update-davical-database






