#!/bin/bash
set -e

export JAVA_OPTIONS="${JAVA_OPTS} ${GN_CONFIG_PROPERTIES}"

GN_BASE_DIR=/opt/geonetwork

### ureditev data dira
echo "Deleting '$DATA_DIR/wro4j-cache.*' files..."
rm -f $DATA_DIR/wro4j-cache.*
echo "Deleting '$DATA_DIR/data/resources/htmlcache/formatter-cache/info-store.*' files..."
rm -f $DATA_DIR/data/resources/htmlcache/formatter-cache/info-store.*
echo "Deleting '$DATA_DIR/harvester*.log' files..."
rm -f $DATA_DIR/harvester*.log
echo "Removing file '$DATA_DIR/index/taxonomy/write.lock', if exists..."
rm -f $DATA_DIR/index/taxonomy/write.lock
echo "Removing files '$DATA_DIR/index/index/*/write.lock', if they exist..."
rm -f $DATA_DIR/index/index/*/write.lock

echo "Replacing data dir formatters, resources, config ..."
rm -rf $DATA_DIR/data/formatter/*
find $DATA_DIR/data/resources/ -mindepth 1 -maxdepth 1 -type d -not -name images -exec rm -rf {} \;
rm -rf $DATA_DIR/config/*
cp -pr $GN_BASE_DIR/WEB-INF/data/data/formatter $DATA_DIR/data
cp -pr $GN_BASE_DIR/WEB-INF/data/data/resources $DATA_DIR/data
cp -pr $GN_BASE_DIR/WEB-INF/data/config $DATA_DIR
###

if ! command -v -- "$1" >/dev/null 2>&1 ; then
	set -- java -jar "$JETTY_HOME/start.jar" "$@"
fi

if [[ "$1" = jetty.sh ]] || [[ $(expr "$*" : 'java .*/start\.jar.*$') != 0 ]]; then
    # Customize context path
    if [ ! -f "{$JETTY_BASE}/webapps/geonetwork.xml" ]; then
        echo "Using $WEBAPP_CONTEXT_PATH for deploying the application"
        cp /usr/local/share/geonetwork/geonetwork_context_template.xml "${JETTY_BASE}/webapps/geonetwork.xml"
        sed -i "s#GEONETWORK_CONTEXT_PATH#${WEBAPP_CONTEXT_PATH}#" "${JETTY_BASE}/webapps/geonetwork.xml"
    fi

    # Delegate on base image entrypoint to start jetty
    exec /docker-entrypoint.sh "$@"
else
    exec "$@"
fi
