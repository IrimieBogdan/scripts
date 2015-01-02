#!/usr/bin/env bash

VERSION="0.1.0"

project_dir=`pwd`
script_dir=${0%/*}

#-------------------------------------------------------------------------------
# Useful Functions
#

print_usage() {
    cat<<HEREDOC
Usage: ${0} <cmd> [<options>] <jenkins-instance> [<deployment-type>[,
            [, <sub-command-args>]]

  OPTIONS:
  -h Print this usage message.
  -v Print script name and version number.

  COMMANDS:
    update
      Produce XML and update/create jobs on given jenkins instance.
    test
      Produce XML output for the given jenkins instance.
        OPTIONS:
        -o <output-dir> Direct XML to given directory.
    delete <glob>
      Using shell glob syntax, delete JJB-managed jobs on given jenkins
      instance.
HEREDOC
}

#-------------------------------------------------------------------------------
# Optional Arg Handling
#

while getopts o:hv OPT; do
    case "$OPT" in
    h)
        print_usage
        exit 0
        ;;
    v)
        message "`basename $0` version ${VERSION}"
        exit 0
        ;;
    o)
        OUTPUT_DIR="${OPTARG}"
        ;;
    \?)
        print_usage
        error "Invalid option."
        ;;
    esac
done

# remove the switches parsed above
shift `expr $OPTIND - 1`

#-------------------------------------------------------------------------------
# Positional Arg Handling
#

COMMAND=${1:-}
JENKINS_INSTANCE=${2:-}
DEPLOYMENT_TYPE=${3:-staging}
GLOB=${4:-*}

if [ -z "$COMMAND" ]
then
	print_usage
	exit $1
fi

if [ -z "$JENKINS_INSTANCE" ]
then
	print_usage
	exit $1
fi

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
JJB_OPTS="--conf ${JENKINS_INSTANCE}/builder.conf"

echo "Running Jenkins Job Builder."
echo
echo "Jenkins instance: ${JENKINS_INSTANCE}"
echo "Deployment type:  ${DEPLOYMENT_TYPE}"

case $COMMAND in
	update)
	COMMAND="jenkins-jobs ${JJB_OPTS} update ${JJB_PATHS}"
	;;
	test)
	if [ ! -z "${OUTPUT_DIR}" ]
	then
		mkdir -p ${OUTPUT_DIR}
		COMMAND="jenkins-jobs ${JJB_OPTS} test -o ${OUTPUT_DIR} ${JJB_PATHS}"
	else
		COMMAND="jenkins-jobs ${JJB_OPTS} test ${JJB_PATHS}"
	fi
	;;
	delete)
	COMMAND="jenkins-jobs ${JJB_OPTS} delete --path ${JJB_PATHS} ${GLOB}"
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
