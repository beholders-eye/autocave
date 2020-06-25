# Not meant to be executed, only sourced

function cavecmd() {
    if [ "${1}" = "sync" ]; then
        CAVECMD="cave sync"
        return
    fi
    if [ "${1}" = "searchidx" ]; then
        # TODO path to the search index
        CAVECMD="cave manage-search-index --create /var/db/paludis/repositories/search.idx"
        return
    fi

    local quiet_redirect=" &>/dev/null"
    if ! $VERBOSE; then trail="$quiet_redirect"; fi
    local target="installed-slots "
    local paludis_cnf=""
    local extra=""
    if [ "${ARCH}" = "x86" ]; then
        target="installed-packages"
        local destination="i686-pc-linux-gnu"
        target="${target}::${destination} "

        # Needs that last blank
        local extra="-mx -4 i686-pc-linux-gnu -Km -km -I */*::installed "
        # Needs that last blank
        paludis_cnf="-E :i686 "
    fi
    if [ -z "${CONTINUE}" ]; then
        CONTINUE="${ARCH}"
    fi

    local subcommand="resolve "
    # TODO enable customization of this
    local depsdepth="-c "
    local nosuggestions="--suggestions ignore "
    local without=""
    CAVEBUILDLOG=""
    if [ "$1" = "resume" ]; then
        depsdepth=""
        subcommand="${1} "
        nosuggestions=""
        CAVEBUILDLOG="/tmp/fixed-example-paludis-build.log"
        ${DRYRUN} || CAVEBUILDLOG="$(mktemp /tmp/paludis-${ARCH}-XXXXXXXXX-build.log)"
        trail=" -Cs -Rr"
    else
        if [ -n "${SKIPIDS}" ]; then
            without="-W ${SKIPIDS} -I ${SKIPIDS} "
        fi
    fi

    CAVECMD="cave ${paludis_cnf}${subcommand}${depsdepth}${target}${extra}${without}${nosuggestions}--resume-file ${WORKDIR}/${CONTINUE}${trail}"
}

