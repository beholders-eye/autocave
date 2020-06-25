#!/usr/bin/bash
# Tries to wrap a cave sync/manage-search-index/resolve/resume run

HERE="$(cd "$(dirname $(readlink -e ${0}))"; pwd -P)"

# Checks for dependencies
function deps_check() {
    local deps="getopt cave sed awk grep mktemp"
    for d in $deps; do
        if ! hash ${d} &>/dev/null; then
            echo "Dep $d not found"
            exit 1
        fi
    done

    for d in ${HERE}/exherbo/{main{,_test}.bash,commands.lib.bash}; do
        if [ ! -f $d ]; then
            echo "Script ${d} not found"
            exit 1
        fi
    done
}

TEMP=`getopt -o hvsxrcauw: --long verbose,sync,searchidx,resume,dry-run,help,continue:,arch:,jobs:,user:,workdir:,skipids: \
             -n 'autocave' -- "$@"`

if [ $? != 0 ] ; then echo "Wrong options..." >&2 ; exit 1 ; fi
eval set -- "$TEMP"

VERBOSE=false
SYNC=false
SEARCHIDX=false
DRYRUN=false
RESUMEONLY=false
CONTINUE=
ARCH=x86_64
JOBS=
RUNAS=beholder
WORKDIR=/home/beholder/Workspaces/Linux/Exherbo/_INSTALL
SKIPIDS=
while true; do
  case "$1" in
    -h | --help ) echo "Paludis \"cave\" wrapper HELP:

  -h | --help         Shows this help message
  -v | --verbose      Prints build log output
  -s | --sync         Syncs with upstream repositories
  -x | --searchidx    Updates cave search index db
  -r | --resume       Skip resolving and just resume
     | --dry-run      Don't run anything, only print out the commands
  -c | --continue     Resume file name
  -a | --arch         Arch target, default is x86_64
  -u | --user         User id to run "cave resolve", must be a member of paludisbuild
  -w | --workdir      Base work directory from where to store resume files and run cave itself
     | --skipids      Package to be skipped, won't be taken into account when resolving
"
        exit 0 ;;
    -v | --verbose ) VERBOSE=true; shift ;;
    -s | --sync ) SYNC=true; shift ;;
    -x | --searchidx ) SEARCHIDX=true; shift ;;
    -r | --resume ) RESUMEONLY=true; shift ;;
    --dry-run ) DRYRUN=true; shift ;;
    -c | --continue ) CONTINUE="$2"; shift 2 ;;
    -a | --arch ) ARCH="$2"; shift 2;
       possiblearchs="x86 x86_64"
       if ! $(echo "${possiblearchs}" | fgrep -q "${ARCH}"); then
           echo "Only support x86 and x86_64 ARCH"
           exit 1
       fi
       ;;
    -j | --jobs ) JOBS="$2"; shift 2 ;;
    -u | --user ) RUNAS="$2"; shift 2 ;;
    -w | --workdir ) WORKDIR="$2"; shift 2 ;;
    --skipids) SKIPIDS="$2"; shift 2 ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

deps_check

source ${HERE}/exherbo/main.bash
