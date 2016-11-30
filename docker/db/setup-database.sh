#!/bin/bash

TEST=`gosu postgres postgres --single <<- EOSQL
   SELECT 1 FROM pg_database WHERE datname='$DB_NAME';
EOSQL`

echo "******CREATING DOCKER DATABASE  $DB_NAME ******"
if [[ $TEST == "1" ]]; then
    # database exists
    # $? is 0
    exit 0
else

USER=`gosu postgres postgres --single <<- EOSQL
   SELECT 1 FROM pg_roles WHERE rolname='$DB_USER';
EOSQL`

echo "******CREATING DOCKER DATABASE USER $DB_USER ******"
if [ $USER == "1" ]
    gosu postgres postgres --single <<- EOSQL
        CREATE ROLE $DB_USER WITH LOGIN ENCRYPTED PASSWORD '${DB_PASS}' CREATEDB;
    EOSQL
    echo ""
    echo "******DOCKER DATABASE USER CREATED******"
fi


gosu postgres postgres --single <<- EOSQL
   CREATE DATABASE $DB_NAME WITH OWNER $DB_USER TEMPLATE template0 ENCODING 'UTF8';
EOSQL

gosu postgres postgres --single <<- EOSQL
   GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
EOSQL
fi

echo ""
echo "******DOCKER DATABASE CREATED******"