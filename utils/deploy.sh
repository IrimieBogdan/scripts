#!/usr/bin/env bash

#-------------------------------------------------------------------------------
# Command line parameters
#

COMMAND=${1:?}
JENKINS_INSTANCE=${2:?}
DEPLOYMENT_TYPE=${3:-staging}
GLOB=${4:-*}

if [ ! "$DEPLOYMENT_TYPE" = "staging" ] && \
	[ ! "$DEPLOYMENT_TYPE" = "production" ]
then
	echo "FAILURE: Invalid deployment type: \"${DEPLOYMENT_TYPE}\""
	exit 1
fi
#-------------------------------------------------------------------------------
# Setup
#

JJB_PATHS="resources:${JENKINS_INSTANCE}/resources:${JENKINS_INSTANCE}/${DEPLOYMENT_TYPE}"
JJB_CONFIG="${JENKINS_INSTANCE}/builder.conf"

echo "Running Jenkins Job Builder."
echo
echo "Jenkins instance: ${JENKINS_INSTANCE}"
echo "Deployment type:  ${DEPLOYMENT_TYPE}"

case $COMMAND in
	update)
	COMMAND="jenkins-jobs --conf ${JJB_CONFIG} update ${JJB_PATHS}"
	;;
	test)
	COMMAND="jenkins-jobs --conf ${JJB_CONFIG} test ${JJB_PATHS}"
	;;
	delete)
	COMMAND="jenkins-jobs --conf ${JJB_CONFIG} delete --path ${JJB_PATHS} ${GLOB}"
	;;
	*)
	echo
	echo "FAILURE: Unrecognized JJB command, \"$COMMAND\""
	exit 1
	;;
esac

echo
echo "Command:          ${COMMAND}"
echo
echo "Output:"
echo

$COMMAND

exit $?
