#!/usr/bin/env bash

set -xeuo pipefail

SB="${HOME}/sandbox/sandbox"
GOAL="${SB} goal"

APPROVAL_FILE='app.teal'
CLEAR_FILE='clear.teal'

CREATOR="MEMFGTIZJVUID7NS7UPVVG2HONT7APIZ4G7CEO25OSLACYQWWGO4ZN3YCM"

${SB} copyTo ${APPROVAL_FILE}
${SB} copyTo ${CLEAR_FILE}

APP_ID=$(${GOAL} app create --creator ${CREATOR} \
	--approval-prog ${APPROVAL_FILE} \
	--clear-prog ${CLEAR_FILE} \
	--global-byteslices 0 --global-ints 0 \
	--local-byteslices 0 --local-ints 0 | \
	grep 'Created app with app index' | awk '{print $6}' | tr -d '\r')

${GOAL} app method -f ${CREATOR} --app-id ${APP_ID} \
	--method "deploy(pay,byte[],byte[])uint64" \
	--arg ${APP_APPROVAL} \
	--arg ${APP_CLEAR}

