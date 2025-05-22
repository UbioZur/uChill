#!/usr/bin/env bash
## ~  UbioZur - https://github.com/UbioZur  ~ ##

# Meant to be sourced at the top of the scripts

# Fail quick and fast
set -ueo pipefail

# Log some Data to the output
# usage: log "Some text to log" 
log() {
	echo -e "\e[1;34muChill\e[0m  $@"
}

# Exit with en error message and code
# usage: die "Error message" 1
die() {
    local -r msg="${1:-script error: 'die msg errCode' msg cannot be empty}"
    local -r errCode="${2:-1}"
    local -r prefix="  \e[1;31mERROR\e[0m  "
	log "$prefix$msg"
	exit $errCode
}

# If Debug, then trace the commands
if [ "${DEBUG}" == "1" ]; then
    log "Build is running in \e[36mDEBUG\e[0m mode"
    set -x
fi

# Quiet commands unless it's debug mode
quiet() {
    local -r command=$@

    if [ "${DEBUG}" == "1" ]; then
        ${command}
        local -r ret="$?"
    else
        ${command} 1> /dev/null
        local -r ret="$?"
    fi
    return $ret
}
