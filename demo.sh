#!/usr/bin/env bash

set -e -u -x -o pipefail

GOAL="goal"
CREATOR="JAQA7FTVZP2ZK32Z7HEVIL5XJZEMTEFV7FRI6BJAT7VUQB6GA7NEBN4KS4"
CHILD_APPROVAL="[6,32,2,1,0,49,24,65,0,22,49,25,129,5,18,64,0,16,54,26,0,128,4,229,72,146,240,18,64,0,9,0,34,67,49,0,50,9,18,67,54,26,1,73,21,129,2,76,82,53,0,52,0,53,4,52,0,21,53,1,35,53,2,52,2,52,1,12,65,0,26,52,4,52,1,52,2,9,34,9,52,0,52,2,85,86,53,4,52,2,34,8,53,2,66,255,222,128,4,21,31,124,117,35,22,87,7,0,80,52,4,21,22,87,7,0,80,52,4,80,176,34,67]"
CHILD_CLEAR="[6,129,1]"

# Deploy Parent
APP_ID=$(${GOAL} app create \
	--creator ${CREATOR} \
	--approval-prog parent.teal --clear-prog clear.teal \
	--global-byteslices 0 --global-ints 0 \
	--local-byteslices 0 --local-ints 0 \
	| grep 'Created app with app index' \
	| awk '{print $6}' \
	| tr -d '\r')

# Get Parent Application Address
APP_ADDR=$(${GOAL} app info --app-id ${APP_ID} \
	| grep 'Application account' \
	| awk '{print $3}' \
	| tr -d '\r')

# Fund Parent
${GOAL} clerk send -f ${CREATOR} \
	-t ${APP_ADDR} \
	-a 100000

# Prepare Algo Payment for deploy method
${GOAL} clerk send -f ${CREATOR} \
	-t ${APP_ADDR} \
	-a 100000 \
	-o pay.txn

# Deploy Child
CHILD_APP_ID=$(${GOAL} app method -f ${CREATOR} \
	--app-id ${APP_ID} \
	--method "deploy(pay,byte[],byte[])uint64" \
	--arg pay.txn --arg ${CHILD_APPROVAL} --arg ${CHILD_CLEAR}\
	--fee 2000 \
	| grep 'succeeded with output' \
	| awk '{print $6}' \
	| tr -d '\r')

# Call Child
${GOAL} app method -f ${CREATOR} \
	--app-id ${CHILD_APP_ID} \
	--method "reverse(string)string" \
	--arg '"This is only a test"'

# Destroy Child
${GOAL} app method -f ${CREATOR} \
	--app-id ${APP_ID} \
	--method "destroy(application)bool" \
	--arg ${CHILD_APP_ID} \
	--fee 3000

