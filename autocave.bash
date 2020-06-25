#!/bin/bash
# Tries to wrap a cave sync/manage-search-index/resolve/resume run

# Checks for dependencies

function deps_check() {
    local deps="getopt cave sed awk"
    for d in $deps; do
        if ! hash ${d} &>/dev/null; then
            echo "Dep $d not found"
            exit 1
        fi
    done

    for d in ${HERE}/exherbo/{main{,_test}.bash,pk_test.bash,commands.lib.bash}; do
        if [ ! -f $d ]; then
            echo "Script ${d} not found"
            exit 1
        fi
    done
}

function findhome() {
    local scriptpath="${0}"
    local scriptname="$(basename ${scriptpath})"
    HERE="${scriptpath/\/${scriptname}/}"
}

TEMP=`getopt -o vdm: --long verbose,sync,searchidx,dry-run,help,continue:,arch:,jobs:,user:,workdir:,skipids: \
             -n 'autocave' -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "$TEMP"

VERBOSE=false
SYNC=false
SEARCHIDX=false
DRYRUN=false
CONTINUE=
ARCH=x86_64
JOBS=
RUNAS=beholder
WORKDIR=/home/beholder/Workspaces/Linux/Exherbo/_INSTALL
SKIPIDS=
while true; do
  case "$1" in
    -h | --help ) echo "Paludis \"cave\" wrapper HELP:

  -v | --verbose      Prints build log output
  -s | --sync         Syncs with upstream repositories
  -x | --searchidx    Updates cave search index db
     | --dry-run      Don't run anything, only print out the commands
  -c | --continue     Resume file name
     | --arch         Arch target, default is x86_64
  -u | --user         User id to run "cave resolve", must be a member of paludisbuild
  -w | --workdir      Base work directory from where to store resume files and run cave itself
     | --skipids      Packages to be skipped, won't be taken into account when resolving
        "
        exit 0 ;;
    -v | --verbose ) VERBOSE=true; shift ;;
    -s | --sync ) SYNC=true; shift ;;
    -x | --searchidx ) SEARCHIDX=true; shift ;;
    --dry-run ) DRYRUN=true; shift ;;
    -c | --continue ) CONTINUE="$2"; shift 2 ;;
    --arch ) ARCH="$2"; shift 2 ;;
    -j | --jobs ) JOBS="$2"; shift 2 ;;
    -u | --user ) RUNAS="$2"; shift 2 ;;
    -w | --workdir ) WORKDIR="$2"; shift 2 ;;
    --skipids) SKIPIDS="$2"; shift 2 ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

findhome
deps_check

HERE=${HERE} VERBOSE=${VERBOSE} SYNC=${SYNC} SEARCHIDX=${SEARCHIDX} DRYRUN=${DRYRUN}\
    ARCH=${ARCH} JOBS=${JOBS} RUNAS=${RUNAS} WORKDIR=${WORKDIR} SKIPDIS=${SKIPIDS} ${HERE}/exherbo/main.bash
