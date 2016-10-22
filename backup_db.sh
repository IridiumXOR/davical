#!/bin/sh
su postgres -c 'pg_dump -Ft davical > /var/lib/postgresql/data/backups/davical_backup.tar'






