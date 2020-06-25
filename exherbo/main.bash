#!/usr/bin/bash

source ${HERE}/exherbo/commands.lib.bash

function sync() {
    cavecmd "sync"

    echo "${CAVECMD}"
    ${DRYRUN} && return

    ${CAVECMD}
}

function searchidx() {
    cavecmd "searchidx"

    echo "${CAVECMD}"
    ${DRYRUN} && return

    ${CAVECMD}
}

function resolve() {
    cavecmd

    echo "${CAVECMD}"
    ${DRYRUN} && return

    su -c "${CAVECMD}" - ${RUNAS}
}

function cleanup() {
    rv=$?
    kill $PID
    exit $rv
}

function resume() {
    cavecmd "resume"

    echo "${CAVECMD} &> ${CAVEBUILDLOG} &"
    ${DRYRUN} && return

    local spinner=false
    if ! $VERBOSE; then
        spinner=true
    fi

    chmod go+r ${CAVEBUILDLOG}
    ${CAVECMD} &> ${CAVEBUILDLOG} &
    PID=$!
    trap "cleanup" INT TERM EXIT

    local i=1
    local sp="/-\|"
    echo -n ' '
    while [ -d /proc/$PID ]
    do
        local relevantline=$(tail -n 1 ${CAVEBUILDLOG} | grep '^[0-9]\+ of [0-9]\+:' | sed -e 's/\n//')
        if $(echo ${relevantline} | fgrep -q "Starting install to"); then
            local packagebit=$(echo ${relevantline} | awk '{print $1 " of " $3 " " $9}')
            relevantline="${packagebit} -- build"
        elif $(echo ${relevantline} | fgrep -q "Starting fetch for"); then
            local packagebit=$(echo ${relevantline} | awk '{print $1 " of " $3 " " $8}')
            relevantline="${packagebit} -- fetch"
        fi
        printf "\b${sp:i++%${#sp}:1}"
        if [ -n "${relevantline}" ]; then
            printf "\b$relevantline\n"
            echo -n ' '
            unset relevantline packagebit
        fi
    done
}

# Dry run
if ! ${DRYRUN}; then
    # Check if we are root
    if [ ${UID} -ne 0 ]; then
        echo "Should be root to run cave sync|manage-search-index|resume"
        exit 1
    fi

else
    echo "Won't execute anything, just show off"
fi

# Let's do this
if ${SYNC}; then
    sync
fi
if ${SEARCHIDX}; then
    searchidx
fi
if ! ${RESUMEONLY}; then
    resolve
fi

resume
