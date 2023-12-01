#!/bin/bash
set -o nounset
set -o errexit

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

readonly MAINDIR=/var/backup/mysqlbackupinno/
readonly DATE=`date +%Y/%m/`
readonly BACKUP_DIR=$MAINDIR/$DATE/
FULL=0
INC=0
#TODO 
#safe remove old backups function

cmdline() {
    local arg=
    for arg
    do
        local delim=""
	case "$arg" in
		--full)		FULL="1" ;;
		--inc)		INC="1" ;;
	esac
    done

}

fullbackup() {
	mkdir -p ${BACKUP_DIR}
	echo "Start new FULL mysql backup in dir ${BACKUP_DIR}"
	innobackupex ${BACKUP_DIR}  \
        --compress \
        --slave-info \
        --rsync \
        --throttle=5000 \
        --lock-wait-threshold=40 \
        --lock-wait-query-type=all \
        --lock-wait-timeout=180 \
        --kill-long-queries-timeout=20 \
        --kill-long-query-type=select 
        echo "Stop  mysql backup in dir ${BACKUP_DIR}"
        sync; echo 2 > /proc/sys/vm/drop_caches



}

incbackup() {
	echo "Start  mysql backup in dir ${BACKUP_DIR}"

	innobackupex ${BACKUP_DIR}  \
        --incremental \
        --incremental-force-scan \
        --compress \
        --slave-info \
        --rsync \
        --throttle=5000 \
        --lock-wait-threshold=40 \
        --lock-wait-query-type=all \
        --lock-wait-timeout=180 \
        --kill-long-queries-timeout=20 \
        --kill-long-query-type=select
	echo "Stop  mysql backup in dir ${BACKUP_DIR}"
        sync; echo 2 > /proc/sys/vm/drop_caches

	
}

main () {
    cmdline $ARGS
    if [ $FULL = 1 ] ;
	then fullbackup 2>&1 | logger -t innobackupex.full -p info
    fi
    if [ $INC = 1 ] 
	then incbackup 2>&1 | logger -t innobackupex.inc -p info
    fi
    if [ $INC = $FULL ] ;
	then echo "nothing to do, exiting"; exit 1;
    fi

}
main

