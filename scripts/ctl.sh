#!/bin/sh

if [ `id|sed -e s/uid=//g -e s/\(.*//g` -eq 0 ]; then
    PARSE_START="HOME=/opt/bitnami/apps/parse NODE_ENV=production /opt/bitnami/nodejs/bin/node /opt/bitnami/nodejs/bin/forever start server.js"
    PARSE_STOP="HOME=/opt/bitnami/apps/parse NODE_ENV=production /opt/bitnami/nodejs/bin/node /opt/bitnami/nodejs/bin/forever stop server.js"
else
    PARSE_START="/opt/bitnami/nodejs/bin/node /opt/bitnami/nodejs/bin/forever start server.js"
    PARSE_STOP="/opt/bitnami/nodejs/bin/node /opt/bitnami/nodejs/bin/forever stop server.js"
fi

PARSE_PROGRAM=/opt/bitnami/apps/parse/htdocs/server.js
PARSE_PID=""
PARSE_STATUS=""
ERROR=0

is_service_running() {
    PARSE_PID=`COLUMNS=400 ps ax | grep "$1" | grep -v "grep" | awk '{print $1}' 2>&1`
    if [ $PARSE_PID ] ; then
        RUNNING=1
    else
        RUNNING=0
    fi
    return $RUNNING
}

is_parse_running() {
    is_service_running "$PARSE_PROGRAM"
    RUNNING=$?
    if [ $RUNNING -eq 0 ]; then
        PARSE_STATUS="parse not running"
    else
        PARSE_STATUS="parse already running"
    fi
    return $RUNNING
}

start_parse() {
    is_parse_running
    RUNNING=$?
    if [ $RUNNING -eq 1  ]; then
        echo "$0 $ARG: parse (pid $PARSE_PID) already running"
        exit
    else 
	    cd /opt/bitnami/apps/parse/htdocs
	    if [ `id|sed -e s/uid=//g -e s/\(.*//g` -eq 0 ]; then
            su daemon -s /bin/sh -c "$PARSE_START"
	    else
            $PARSE_START
        fi
    fi

    COUNTER=20
    while [ $RUNNING -eq 0 ] && [ $COUNTER -ne 0 ]; do
        COUNTER=`expr $COUNTER - 1`
        sleep 1
        is_parse_running
        RUNNING=$?
    done

    if [ $RUNNING -eq 0 ]; then
        ERROR=1
    fi
    if [ $ERROR -eq 0 ]; then
	    echo "$0 $ARG: Parse started"
    else
	    echo "$0 $ARG: parse could not be started"
	    ERROR=3
    fi

}

stop_parse() {
    NO_EXIT_ON_ERROR=$1
    is_parse_running
    RUNNING=$?
    if [ $RUNNING -eq 0 ]; then
        echo "$0 $ARG: $PARSE_STATUS"
        if [ "x$NO_EXIT_ON_ERROR" != "xno_exit" ]; then
            exit
        else
            return
        fi
    fi

    cd /opt/bitnami/apps/parse/htdocs
    if [ `id|sed -e s/uid=//g -e s/\(.*//g` -eq 0 ]; then
        su daemon -s /bin/sh -c "$PARSE_STOP"
    else
        $PARSE_STOP
    fi

    COUNTER=20
    while [ $RUNNING -eq 1 ] && [ $COUNTER -ne 0 ]; do
        COUNTER=`expr $COUNTER - 1`
        sleep 1
        is_parse_running
        RUNNING=$?
    done

    if [ $RUNNING -eq 0 ]; then
            echo "$0 $ARG: parse stopped"
        else
            echo "$0 $ARG: parse could not be stopped"
            ERROR=4
    fi
}



if [ "x$1" = "xstart" ]; then
    start_parse
elif [ "x$1" = "xstop" ]; then
    stop_parse
elif [ "x$1" = "xstatus" ]; then
    is_parse_running
    echo "$PARSE_STATUS"
fi

exit $ERROR
