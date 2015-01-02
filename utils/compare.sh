#!/usr/bin/env bash

VERSION="0.1.0"

project_dir=`pwd`
script_dir=${0%/*}

#-------------------------------------------------------------------------------
# Useful Functions
#

print_usage() {
    cat<<HEREDOC
Usage: ${0} [<options>] <jenkins-instance> <revision-A> [<revision-B>]
  Will provide a unified diff of the XML output by JJB between <revision-A> and
  <revision-B> of ci-job-configs. If no <revision-B> is specified, then use the
  current working directory to produce output to be passed as the right-hand
  argument to 'diff -ur'.

  <revision-A> and <revision-B> must be valid git SHA since the clone repo will
  not necessarily contain the same branches as the local working directory.

  OPTIONS:
  -h          Print this usage message.
  -d <deploy> Use specified deployment type (see ./utils/deploy.sh usage for
              more details)
  -D          Debug mode. Leave the directory in which comparison takes place
              for user inspection
  -o <rundir> Use specified run directory to output XML contents.
  -v          Print script name and version number.
HEREDOC
}

gen_jjb_output() {
	local cijobconfig_dir=${1:?}
	local outdir=${2:?}
	local revision=${3:-}

	pushd $cijobconfig_dir
	if [ ! -z "${revision}" ]
	then
		git checkout ./
		git checkout $revision
	fi

	$project_dir/utils/deploy.sh -o $outdir test $JENKINS_INSTANCE $DEPLOYMENT_TYPE

	popd
}

#-------------------------------------------------------------------------------
# Variable defaults
#

DEPLOYMENT_TYPE="staging"
RUNDIR="$(mktemp -d /tmp/ci-job-configs_XXXXXX)"

#-------------------------------------------------------------------------------
# Parse environment and command line
#

while getopts d:o:Dhv OPT; do
    case "$OPT" in
    d)
        DEPLOYMENT_TYPE="${OPTARG}"
        ;;
    D)
        LEAVE_RUNDIR="yes"
        ;;
    h)
        print_usage
        exit 0
        ;;
    o)
        RUNDIR="${OPTARG}"
        ;;
    v)
        message "`basename $0` version ${VERSION}"
        exit 0
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

JENKINS_INSTANCE=${1:-}
REVISION_A=${2:-}
REVISION_B=${3:-}

if [ -z "$JENKINS_INSTANCE" ]
then
	print_usage
	exit $1
fi

if [ -z "$REVISION_A" ]
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
# Additional variables
#

TMP_REPO="$RUNDIR/repo"
A_OUTDIR="$RUNDIR/a"
B_OUTDIR="$RUNDIR/b"

#-------------------------------------------------------------------------------
# Meat and Potatoes
#

set -x

# clone ci-job-configs repo to avoid interfering with local working directory
# changes
git clone ./ $TMP_REPO

# generate A output
gen_jjb_output $TMP_REPO $A_OUTDIR $REVISION_A

# generate B output
if [ -z "$REVISION_B" ]
then # use working directory
	gen_jjb_output $project_dir $B_OUTDIR
else # use specified git revision
	gen_jjb_output $TMP_REPO $B_OUTDIR $REVISION_B
fi

# diff A vs B

diff -ur $A_OUTDIR $B_OUTDIR

#-------------------------------------------------------------------------------
# Cleanup
#

if [ -z "$LEAVE_RUNDIR" ]
then
	rm -rf "$RUNDIR"
fi

