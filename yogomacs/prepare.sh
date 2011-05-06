#!/bin/sh
PORT=$1
NAME=$2
RELEASE=${3:-0}

if [ -z "$PORT" ] || [ -z "$NAME" ]; then
    echo "Usage: " 1>&2
    echo "	$0 PORT CONFIG-NAME" 1>&2
    exit 1
fi

set -x
bash ./autogen.sh
./configure --with-rpm-release=$RELEASE --with-vhost-port=$PORT --with-vhost-servername=localhost --with-config-name=$NAME
make rpm
sudo rpm -e yogomacs-$NAME
sudo rpm  -Uvh build/RPMS/noarch/yogomacs-${NAME}*.rpm
