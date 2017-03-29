#!/bin/bash
#
# orchestrator daemon
#
# chkconfig: 345 20 80
# description: orchestrator daemon
# processname: orchestrator
### BEGIN INIT INFO
# Provides: orchestrator
# Required-Start: $network $remote_fs
# Required-Stop: $network $remote_fs
# Default-Start: 3 4 5
# Default-Stop: 0 1 2 6
# Short-Description: orchestrator daemon
# Description: orchestrator: MySQL replication management and visualization
### END INIT INFO

# Source LSB function library.
. /lib/lsb/init-functions

NAME=orchestrator
DESC="orchestrator: MySQL replication management and visualization"

exec=/usr/bin/orchestrator
prog=$(basename $exec)
OPTS="-verbose http"
DAEMON_PATH="/usr/share/orchestrator"

PIDFILE=/var/run/$NAME.pid
DAEMONOPTS="--pidfile=$PIDFILE"

ulimit -n 16384

# The orchestrator profile file can be used to inject pre-service execution
# scripts, such as exporting variables or whatever. It's yours!
PROFILE=/etc/${NAME}/orchestrator_profile
[ -f $PROFILE -a -r $PROFILE ] && . $PROFILE

RETVAL=0

start() {
    printf "%-50s" "Starting $NAME..."
    cd $DAEMON_PATH
    start_daemon $DAEMONOPTS "$exec $OPTS &>>/var/log/${NAME}.log"
    RETVAL=$?
}

status() {
    local pid

    pid=`pidofproc -p $PIDFILE $prog`
    RETVAL=$?
    case $RETVAL in
        0)
        echo "$prog is running ($pid)."
        ;;
        *)
        echo "$prog is not running." >&2
        ;;
    esac
}

stop() {
    printf "%-50s" "Stopping $NAME"
    killproc -p $PIDFILE $prog -TERM
    RETVAL=$?
}

reload() {
    printf "%-50s" "Reloading $NAME"
    killproc -p $PIDFILE $prog -HUP
    RETVAL=$?
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    restart)
        stop
        start
        ;;
    reload)
        reload
        ;;
    *)
        echo "Usage: $0 {status|start|stop|restart|reload}"
        RETVAL=-1
esac
exit $RETVAL
