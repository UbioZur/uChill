#!/usr/bin/env bash
## ~  UbioZur - https://github.com/UbioZur  ~ ##

source "/ctx/libCommon.sh"


#log "Fix \e[36m/opt\e[0m to make it writable"
#quiet rmdir -v /opt
#quiet mkdir -v /var/opt
#quiet ln -s -T -v /var/opt /opt

#log "Building DNF Cache"
#quiet dnf -y makecache
