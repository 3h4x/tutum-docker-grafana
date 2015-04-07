#!/bin/bash

set -e

INFLUXDB_PASS=${INFLUXDB_ENV_INFLUXDB_INIT_PWD:-${INFLUXDB_PASS}}
INFLUXDB_PASS=${INFLUXDB_1_ENV_INFLUXDB_INIT_PWD:-${INFLUXDB_PASS}}

ELASTICSEARCH_USER=${ELASTICSEARCH_ENV_ELASTICSEARCH_USER:-${ELASTICSEARCH_USER}}
ELASTICSEARCH_USER=${ELASTICSEARCH_1_ENV_ELASTICSEARCH_USER:-${ELASTICSEARCH_USER}}
ELASTICSEARCH_PASS=${ELASTICSEARCH_ENV_ELASTICSEARCH_PASS:-${ELASTICSEARCH_PASS}}
ELASTICSEARCH_PASS=${ELASTICSEARCH_1_ENV_ELASTICSEARCH_PASS:-${ELASTICSEARCH_PASS}}

if [ "${ELASTICSEARCH_HOST}" == "**None**" ]; then
    unset ELASTICSEARCH_HOST
fi

if [ "${ELASTICSEARCH_USER}" == "**None**" ]; then
    unset ELASTICSEARCH_USER
fi

if [ "${ELASTICSEARCH_PASS}" == "**None**" ]; then
    unset ELASTICSEARCH_PASS
fi

if [ "${HTTP_PASS}" == "**Random**" ]; then
    unset HTTP_PASS
fi

sed -i.bak "s/HTTP_PORT/$HTTP_PORT/g" /etc/nginx/sites-enabled/default.conf
rm /etc/nginx/sites-enabled/default.conf.bak

sed -i.bak "s/HTTP_INFLUXDB_PORT/$HTTP_INFLUXDB_PORT/g" /etc/nginx/sites-enabled/influxdb.conf
rm /etc/nginx/sites-enabled/influxdb.conf.bak

sed -i.bak "s/INFLUXDB_HOST/$INFLUXDB_HOST/g" /etc/nginx/sites-enabled/influxdb.conf
rm /etc/nginx/sites-enabled/influxdb.conf.bak

sed -i.bak "s/INFLUXDB_PORT/$INFLUXDB_PORT/g" /etc/nginx/sites-enabled/influxdb.conf
rm /etc/nginx/sites-enabled/influxdb.conf.bak

if [ ! -f /.basic_auth_configured ]; then
    /set_basic_auth.sh
fi

if [ ! -f /.influx_db_configured ]; then
    /set_influx_db.sh
fi

if [ ! -f /.elasticsearch_configured ]; then
    /set_elasticsearch.sh
fi

echo "=> Starting and running Nginx..."
/usr/sbin/nginx
