#!/usr/bin/env bash

#CHECK IF THE DAVICAL DATABASE EXISTS, OTHERWISE INITIALIZE IT
INITIALIZED_DB=$(su postgres -c "psql -l" | grep -c davical)
if [[ $INITIALIZED_DB == 0 ]]; then
su postgres -c '/usr/share/davical/dba/create-database.sh davical 12345'
fi
unset INITIALIZED_DB

#UPDATE ALWAYS THE DATABASE
/usr/share/davical/dba/update-davical-database

