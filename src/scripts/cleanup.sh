#!/usr/bin/env bash
## ~  UbioZur - https://github.com/UbioZur  ~ ##

source "/ctx/libCommon.sh"

shopt -s extglob

log "Cleanup orphan dependencies"
quiet dnf -y autoremove

log "Cleanup dnf cache"
quiet dnf -y clean all

log "Disable repositories"
quiet sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-cisco-openh264.repo

log "Cleanup temporary files"
quiet rm -rf /tmp/* || true
quiet rm -rf /usr/etc || true
quiet rm -rf /boot || true
quiet mkdir -vp /boot || true

shopt -s extglob
quiet rm -rf /var/!(cache) || true
quiet rm -rf /var/cache/!(libdnf5) || true
quiet mkdir -vp /var/tmp
quiet chmod -R 1777 /var/tmp
