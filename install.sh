#!/usr/bin/env bash

set -exuo pipefail

##
# Configuration
##

# Host, username, and home directory on the the dokku server
DOKKU_HOST=dokku-dev.gdgfribourg.ch
DOKKU_SSH=ubuntu@$DOKKU_HOST
DOKKU_HOME_DIR=/home/ubuntu

# Dokku apps and resource names
PREFIX=bb

NETWORK="${PREFIX}network"

APP_MYSQL="${PREFIX}mysql"
APP_CASSANDRA="${PREFIX}cassandra"
APP_BBDATA="${PREFIX}api"

APP_PROMETHEUS="${PREFIX}prom"
APP_GRAFANA="${PREFIX}graf"

##
# Generic functions
##

function header() {
  echo "#################"
  echo "$1"
  echo "################"
}

function git_push() {
  git init .
  git add .
  git commit -m "dokku deploy"
  git remote remove dokku || true
  git remote add dokku "dokku@$DOKKU_HOST:$1"
  git push dokku master:master
  rm -rf .git
}

##
# Dokku resource creation functions
##

function setup() {
  header "Setup"
  ssh -t $DOKKU_SSH <<EOF
dokku network:create $NETWORK
EOF
  echo "Done."
}

function setup_mysql() {

  header "Setup MySQL"

  echo "Copying init files ... "
  ssh -t $DOKKU_SSH "mkdir mysql-init || true"
  scp mysql/*.sql $DOKKU_SSH:mysql-init

  echo "Creating dokku app..."
  ssh -t $DOKKU_SSH <<EOF
set -ex
sudo dokku plugin:install https://github.com/dokku/dokku-mysql.git mysql
dokku mysql:create $APP_MYSQL --custom-env "LANG=C.UTF-8" --image-version 8.0.14 --password "bbdata-admin" --root-password "root"

cd mysql-init
sed 's/bbdata2/$APP_MYSQL/g' bbdata2-structure.sql | dokku mysql:import bbmysql
dokku mysql:import $APP_MYSQL < test-data.sql
EOF

  echo "Done."
}

function setup_cassandra() {

  header "Setup Cassandra"

  echo "Creating dokku app..."
  ssh -t $DOKKU_SSH <<EOF
set -ex
dokku apps:create $APP_CASSANDRA
dokku network:set $APP_CASSANDRA attach-post-create $NETWORK
dokku storage:mount $APP_CASSANDRA /var/lib/dokku/data/storage/$APP_CASSANDRA:/var/lib/cassandra
EOF

  echo "Pushg docker image ..."
  cd cassandra
  git_push $APP_CASSANDRA
  cd ..

  echo "Setting prometheus metrics port ..."
  ssh -t $DOKKU_SSH "dokku proxy:ports-set $APP_CASSANDRA http:7070:7070"
  echo "Done."
}

function setup_bbdata() {

  header "Setup BBData"

  echo "Creating dokku app..."
  ssh -t $DOKKU_SSH <<EOF
set -ex
dokku apps:create $APP_BBDATA
dokku network:set $APP_BBDATA attach-post-create $NETWORK
dokku config:set $APP_BBDATA CASSANDRA_HOST=$APP_CASSANDRA.web.1

dokku mysql:link $APP_MYSQL $APP_BBDATA -a BB_DATABASE \
  -q "autoReconnect=true&useUnicode=true&characterEncoding=UTF-8&allowMultiQueries=true&allowPublicKeyRetrieval=true&serverTimezone=UTC"
EOF

  cd bbdata-api
  git_push $APP_BBDATA
  cd ..

  echo "Setting port..."
  ssh -t $DOKKU_SSH "dokku proxy:ports-set $APP_BBDATA http:80:8080 http:8111:8111"

  echo "Done."
}

function setup_prometheus() {
  header "Setup Prometheus"

  echo "Creating config file ..."
  ssh -t $DOKKU_SSH "mkdir bbprom-config || true"
  cd prom
  TMP_FILE=prometheus.yml.tmp
  export APP_BBDATA APP_CASSANDRA
  envsubst <prometheus.yml >$TMP_FILE
  echo "Config file is:"
  cat $TMP_FILE
  echo
  scp $TMP_FILE $DOKKU_SSH:bbprom-config/prometheus.yml
  rm $TMP_FILE
  cd ..

  echo "Creating app ..."
  ssh -t $DOKKU_SSH <<EOF
set -ex
dokku apps:create $APP_PROMETHEUS
dokku network:set $APP_PROMETHEUS attach-post-create $NETWORK

dokku storage:mount $APP_PROMETHEUS $DOKKU_HOME_DIR/bbprom-config:/etc/prometheus
dokku storage:mount $APP_PROMETHEUS /var/lib/dokku/data/storage/$APP_PROMETHEUS:/prometheus

sudo mkdir /var/lib/dokku/data/storage/$APP_PROMETHEUS || true
sudo chmod a+w /var/lib/dokku/data/storage/$APP_PROMETHEUS

docker pull prom/prometheus:v2.25.0
docker tag prom/prometheus:v2.25.0 dokku/$APP_PROMETHEUS:latest
dokku tags:deploy $APP_PROMETHEUS latest
EOF

  echo "Done."
}

function setup_grafana() {
  header "Setup Grafana"
  ssh -t $DOKKU_SSH <<EOF
set -ex
dokku apps:create $APP_GRAFANA
dokku network:set $APP_GRAFANA attach-post-create $NETWORK

dokku storage:mount $APP_GRAFANA /var/lib/dokku/data/storage/$APP_GRAFANA:/var/lib/grafana

sudo mkdir /var/lib/dokku/data/storage/$APP_GRAFANA || true
sudo chmod a+w /var/lib/dokku/data/storage/$APP_GRAFANA

docker pull grafana/grafana:7.4.2
docker tag grafana/grafana:7.4.2 dokku/$APP_GRAFANA:latest
dokku tags:deploy $APP_GRAFANA latest
EOF
  echo "Done."
}

##
# Execution
##

setup
setup_mysql
setup_cassandra
setup_bbdata
setup_prometheus
setup_grafana
