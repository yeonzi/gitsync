#!/usr/bin/env bash

CONF_FILE=.gitsync_conf

CMD_STATUS="git status --porcelain"
CMD_STAGE="git add --all"
CMD_COMMIT_MSG="echo [AUTO] git-sync auto commit"
CMD_COMMIT="git commit -m"
CMD_PUSH="git push --porcelain --force"
CMD_PULL="git pull -q"

SYNC_TIMEOUT=10
LOG_FILE=/dev/stdout

write_log () {
	TIME_NOW=$(date)
	echo "${TIME_NOW}: ${1}" >> $LOG_FILE
}

git_commit_all () {
	write_log "Preparing commit"

	STAGE_STATUS=$($CMD_STAGE)

	COMMIT_MSG=$($CMD_COMMIT_MSG)
	COMMIT_STATUS=$($CMD_COMMIT "${COMMIT_MSG}")
}

git_push () {
	write_log "Pushing to Remote"
	PUSH_STATUS=$($CMD_PUSH)
}

git_pull () {
	write_log "Syncing Remote"
	PULL_STATUS=$($CMD_PULL)
}

if [[ -e $CONF_FILE ]]; then
	chmod +x ${CONF_FILE}
	. ${CONF_FILE}
fi

WORK_DIR=$(pwd)
write_log "Started at ${WORK_DIR}"

while true; do

	if [[ -e $CONF_FILE ]]; then
		. ${CONF_FILE}
	fi

	GIT_STATUS=$($CMD_STATUS)

	if [[ -n $GIT_STATUS ]]; then
		git_commit_all
		git_pull
		git_push

	else
		write_log "Local repository is clean."
		git_pull

	fi

	sleep ${SYNC_TIMEOUT}
done
