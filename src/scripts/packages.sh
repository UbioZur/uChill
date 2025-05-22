#!/usr/bin/env bash
## ~  UbioZur - https://github.com/UbioZur  ~ ##

source "/ctx/libCommon.sh"

# Install packages from file
# usage: installPkgsFromFile path/file.pkg
installPkgsFromFile() {
    local -r file="$@"
    if [[ ! -f $file ]]; then
        die "File \e[36m${file}\e[0m does not exist!" 1
    fi
	log "Installing packages from \e[36m${file}\e[0m"
	grep -Ev '^#' $file | xargs dnf -y --setopt=install_weak_deps=False install --allowerasing
}

removePkgsFromFile() {
	local -r file="$@"
    if [[ ! -f $file ]]; then
        die "File \e[36m${file}\e[0m does not exist!" 1
    fi
	log "Removing packages from \e[36m${file}\e[0m"
	grep -Ev '^#' $file | xargs dnf -y remove 	
}

log "Build DNF Cache"
quiet dnf -y makecache

installPkgsFromFile "/ctx/base.pkg"

installPkgsFromFile "/ctx/kde.pkg"
log "Enable graphical boot target for \e[36msddm\e[0m"
quiet systemctl set-default graphical.target
quiet systemctl enable sddm.service

removePkgsFromFile "/ctx/remove.pkg"

log "Really trying to force firefox out!"
quiet rpm -e firefox-langpacks
quiet rpm -e firefox

log "Install flathub"
#quiet flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
quiet systemctl enable uchill-fb-add-flathub.service
log "Bruteforce against fedora auto installing their flatpak"
quiet systemctl disable flatpak-add-fedora-repos.service
