#!/usr/bin/env bash

CONF_FILE=.gitsync_conf

CMD_STATUS="git status --porcelain"

SYNC_TIMEOUT=10
LOG_FILE=/dev/stdout

write_log () {
	TIME_NOW=$(date)
	echo "${TIME_NOW}: ${1}" >> $LOG_FILE
}

if [[ -e $CONF_FILE ]]; then
	chmod +x ${CONF_FILE}
	exec ${CONF_FILE}
fi

write_log "Started."

while true; do

	GIT_STATUS=$($CMD_STATUS)

	if [[ -z $GIT_STATUS ]]; then
		write_log "Local repository is clean."
	else
		write_log "Preparing commit."
		git add --all
		git commit -m "[AUTO] git-sync auto commit"

	fi

	write_log "Fetching remote"
	git pull --rebase

	if [[ -n $GIT_STATUS ]]; then
		write_log "Push to remote"
		git push
	fi

	sleep ${SYNC_TIMEOUT}
done
