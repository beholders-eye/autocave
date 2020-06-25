#/usr/bin/pkexec /usr/bin/bash
#!/usr/bin/bash

source ${HERE}/exherbo/commands.lib.bash

function sync() {
    cavecmd "sync"

    echo "${CAVECMD}"
    ${CAVECMD}
}

function searchidx() {
    cavecmd "searchidx"

    echo "${CAVECMD}"
    ${CAVECMD}
}

function resolve() {
    cavecmd

    echo "${CAVECMD}"
    su - $RUNAS -c ${CAVECMD}
}

function cleanup() {
    rv=$?
    kill $PID
    exit $rv
}

function resume() {
    cavecmd "resume"

    local spinner=false
    if ! $VERBOSE; then
        spinner=true
    fi

    echo "${CAVECMD}"
    ${CAVECMD}
    PID=$!
    trap "cleanup" INT TERM EXIT

    local i=1
    local sp="/-\|"
    echo -n ' '
    while [ -d /proc/$PID ]
    do
        local relevantline=$(tail -n 1 ${CAVEBUILDLOG} | grep '[0-9]\+ of [0-9]\+')
        printf "\b${sp:i++%${#sp}:1}"
        if [ -n "${relevantline}" ]; then
            printf "\b$relevantline\n"
            echo -n ' '
            unset relevantline
        fi
    done
}

# Dry run
if ! ${DRYRUN}; then
    # Let's do this
    if ${SYNC}; then
        sync
    fi
    if ${SEARCHIDX}; then
        searchidx
    fi
    resolve
    resume
else
    echo "DRYRUN=${DRYRUN}, so won't execute anything, just show off:"
    cavecmd
    echo -e "Resolve command:\n${CAVECMD}"

    cavecmd "resume"
    echo -e "Resume command:\n${CAVECMD}"

    cavecmd "sync"
    echo -e "Sync command:\n${CAVECMD}"

    cavecmd "searchidx"
    echo -e "Search Index command:\n${CAVECMD}"

    rm -vf ${CAVEBUILDLOG}
fi
