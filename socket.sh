#!/bin/bash
# chkconfig: 2345 94 14
# description: App Server

export LANG=zh_CN.UTF8
APP_MAINFUC=com.cmz.GameDaemon
GAME_USER=www
#RMI_HOST=127.0.0.1
#RMI_PORT=8080
GAME_NAME=myapplication

JAVA_HOME=/data/www/jdk8

CSVR_HOME=/data/www/${GAME_NAME}
DAEMON_HOME=/data/www/${GAME_NAME}/bin
PID_FILE=${CSVR_HOME}/pid.pid
CLASSPATH=$CSVR_HOME/myapplication.jar


if [ ! -f $JAVA_SBIN ]
then
        echo "$GAME_NAME startup: $JAVA_SBIN not exists!"
        exit
fi

start() {
	cd ${CSVR_HOME}
#        ulimit -HSn 65536

	if [ ! -d $CSVR_HOME/logs ];then
	mkdir -p $CSVR_HOME/logs
	fi
	chown -R $GAME_USER:$GAME_USER ${CSVR_HOME}
        cat /dev/null > ${CSVR_HOME}/logs/error.log
        JVM_OPTS="-server -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5010 -Xmx2048M -Xms2048M -Xmn500M -XX:PermSize=256M -XX:MaxPermSize=512M -Xss256K -XX:+DisableExplicitGC -XX:SurvivorRatio=4 -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection -XX:CMSFullGCsBeforeCompaction=0 -XX:+CMSClassUnloadingEnabled -XX:LargePageSizeInBytes=128M -XX:+UseFastAccessorMethods -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=60 -XX:SoftRefLRUPolicyMSPerMB=0"

        ulimit -n 65535
        $DAEMON_HOME/jsvc \
        -user $GAME_USER \
        -home $JAVA_HOME \
        -wait 300 \
        -pidfile $PID_FILE \
        -errfile ${CSVR_HOME}/logs/error.log \
        $JVM_OPTS \
        -cp $CLASSPATH \
        $APP_MAINFUC

        ret=$?
        if [ $ret -eq 0 ]
        then
                echo "Starting OK"
        else
                echo "Starting NO"
        fi

        #chown -R $GAME_USER:$GAME_USER $CSVR_HOME/logs/console.log
        chown -R $GAME_USER:$GAME_USER $CSVR_HOME/logs
        chown -R $GAME_USER:$GAME_USER $PID_FILE
}

stop() {
	cd ${CSVR_HOME}
	$DAEMON_HOME/jsvc -stop -pidfile $PID_FILE $APP_MAINFUC
        ret=$?
        if [ $ret -eq 0 ]
        then
		echo "Stopping OK"
        else
		echo "Stopping NO"
        fi
}

restart() {
        stop
        sleep 3
        start
}

case "$1" in
        start)
        start
        ;;
        stop)
        stop
        ;;
        restart)
        restart
        ;;
        *)
        echo "Error paras"
        exit 1
esac
