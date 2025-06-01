## ~  UboZur - https://github.com/UbioZur  ~ ##

set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

##
##   This just file is used to help with the development and deployement of
## Stas Atomic Desktop.
##

[private]
@_default:
    echo ""
    echo -e "    ========== ========== ========== =========="
    echo -e "    ==         \e[1;34muChill Atomic Desktop\e[0m          =="
    echo -e "    ========== ========== ========== =========="
    echo ""
    just --list

##
## Group to manage the justfiles
##

alias list := just-list
alias edit := just-edit

# List the available commands
[group('Justfile')]
@just-list:
    just --list

# Run checks on the justfiles
[group('Justfile')]
just-check:
    #!/usr/bin/env bash
    set -euo pipefail
    exitCode=0
    echo -e "  \e[1;34mjust-check\e[0m  Checking syntax"
    find . -type f \( -name "*.just" -o -iname "justfile" \) | while read -r file; do
        echo -e "  \e[1;34mjust-check\e[0m  File: \e[36m${file}\e[0m"
        just --unstable --fmt --check -f $file || exitCode=1
    done
    exit $exitCode

# Check and fix broken just files
[group('Justfile')]
just-fix: && just-check
    #!/usr/bin/env bash
    set -euo pipefail
    exitCode=0
    echo -e "  \e[1;34mjust-fix\e[0m  Checking Files"
    find . -type f \( -name "*.just" -o -iname "justfile" \) | while read -r file; do
        echo -e "  \e[1;34mjust-fix\e[0m  File: \e[36m${file}\e[0m"
        if ! just --unstable --fmt --check -f $file; then
            echo -e "  \e[1;34mjust-fix\e[0m  Fixing: \e[36m${file}\e[0m"
        fi
        just --unstable --fmt -f $file || exitCode=1
    done
    exit $exitCode

# Open this file to edit it
[group('Justfile')]
@just-edit: && just-check
    echo -e "  \e[1;34mjust-edit\e[0m  Editing the \e[36mjustfile\e[0m"
    $EDITOR justfile

##
## Group to manage scripts
##

# Run Checks on shell scripts
[group('Scripts')]
scripts-check:
    #!/usr/bin/env bash
    set -euo pipefail
    exitCode=0
    echo -e "  \e[1;34mscripts-check\e[0m  Checking Scripts"
    for file in $(find . | grep '^.**\.sh$'); do
        echo -e "  \e[1;34mscripts-check\e[0m  File: \e[36m${file}\e[0m"
        [[ -x "$file" ]] && continue
        echo -e "\e[1;34mScripts\e[0m  \e[1;31mERROR\e[0m  Need to be executable \e[36m${file}\e[0m"
        exitCode=1
    done
    echo -e "  \e[1;34mscripts-check\e[0m  Checking githooks"
    for file in $(find ./githooks/*); do
        echo -e "  \e[1;34mscripts-check\e[0m  File: \e[36m${file}\e[0m"
        [[ -x "$file" ]] && continue
        exitCode=1
        echo -e "\e[1;34mScripts\e[0m  \e[1;31mERROR\e[0m  Need to be executable \e[36m${file}\e[0m"
    done
    exit $exitCode

# Fix Executable bit on scripts
[group('Scripts')]
scripts-fix: && scripts-check
    #!/usr/bin/env bash
    set -ueo pipefail
    echo -e "  \e[1;34mscripts-check\e[0m  Fixing Scripts"
    for file in $(find . | grep '^.**\.sh$'); do
        [[ -x "$file" ]] && continue
        echo -e "  \e[1;34mscripts-check\e[0m  Fixing \e[36m${file}\e[0m"
        chmod u+x ${file}
    done
    echo -e "  \e[1;34mscripts-check\e[0m  Fixing githooks"
    for file in $(find ./githooks/*); do
        [[ -x "$file" ]] && continue
        echo -e "  \e[1;34mscripts-check\e[0m  Fixing \e[36m${file}\e[0m"
        chmod u+x ${file}
    done
    echo -e "  \e[1;34mscripts-check\e[0m  Running checks on scripts"

##
## Group to manage Git commands
##

alias dev := git-dev

# Setup git hooks
[group('Git')]
git-hooks:
    #!/usr/bin/env bash
    set -ueo pipefail
    echo -e "  \e[1;34mgit-hooks\e[0m  Setting up git hooks symlink"
    if ! git rev-parse --is-inside-work-tree &> /dev/null ; then
        echo -e "  \e[1;34mgit-hooks\e[0m  \e[1;31mERROR\e[0m  It does not seem to be a git directory"
        exit 1
    fi
    for file in githooks/*; do
      ln -svf "../../$file" .git/hooks/
    done
    #cp -vrs "githooks/*" ".git/hooks/"

# Clean all git stashes
[group('Git')]
@git-clean:
    echo -e "  \e[1;34mgit-clean\e[0m  Clearing up git stashes"
    git stash clear

# Switch to the dev branch
[group('Git')]
@git-dev:
    echo -e "  \e[1;34mgit-dev\e[0m  Switching to the dev branch"
    git switch dev

# Switch to the main branch
[group('Git')]
@git-main:
    echo -e "  \e[1;34mgit-dev\e[0m  Switching to the main branch"
    git switch main

# Check git does not have files that shouldn't be there
[group('Git')]
git-check:
    #!/usr/bin/env bash
    set -ueo pipefail
    # Make sure we do not commit cosign private key
    readonly cosignFile="cosign.key"
    if [ ! -f "$cosignFile" ]; then
      echo -e "  \e[1;34mgit-check\e[0m  No \e[36m${cosignFile}\e[0m file found in the repository."
      exit 0
    fi
    if git ls-files --error-unmatch "$cosignFile" >/dev/null 2>&1; then
      echo -e "  \e[1;34mgit-check\e[0m  \e[1;31mERROR\e[0m  File \e[36m${cosignFile}\e[0m is tracked by Git but shoudln't!"
      exit 1
    elif git diff --cached --name-only | grep -q "^$cosignFile$"; then
      echo -e "  \e[1;34mgit-check\e[0m  \e[1;31mERROR\e[0m  File \e[36m${cosignFile}\e[0m is staged for commit but shoudln't!"
      exit 1
    fi
    echo -e "  \e[1;34mgit-check\e[0m  File \e[36m${cosignFile}\e[0m is not being sent to git."

##
## Groups to manage Checks
##

alias fix := check-fix
alias checks := check-all

# Perform a quick check on multiple files
[group('Checks')]
check-quick: just-check scripts-check git-check

# Perform a full check of the project
[group('Checks')]
check-all $env="local.env": check-quick check-build

# Check the justfiles (Same as just-check)
[group('Checks')]
check-just: just-check

# Check the container can build
[group('Checks')]
check-build $env="local.env": (_build-pod env)

# Check the scripts (Same as scripts-check)
[group('Checks')]
check-scripts: scripts-check

# Perform fix on multiple files
[group('Checks')]
check-fix: just-fix scripts-fix

# Check we don't git files we shouldn't (Same as git-check)
[group('Checks')]
check-git: git-check

##
## Groups to manage builds
##

# Check that the container can be built
[group('Build')]
[private]
_build-pod $date="":
    #!/usr/bin/env bash
    set -ueo pipefail
    echo -e "  \e[1;34mpod-build\e[0m  Checking container can build"
    [[ -z $date ]] && date=$(date --utc +%Y%m%d%H%M)
    source .env
    [[ "${NVIDIA}" == "Y" ]] && VARIANT="-nvidia" || VARIANT=""
    readonly FULLNAME=${IMAGE_NAME,,}${VARIANT,,}
    echo -e "  \e[1;34mpod-build\e[0m  Building Container \e[36m${FULLNAME}\e[0m"
    podman build --pull=newer \
       --build-arg "BASE_IMAGE=${BASE_IMAGE}" \
       --build-arg "BASE_VERSION=${BASE_VERSION}" \
       --build-arg "DEBUG=${DEBUG}" \
       --build-arg "IMAGE_NAME=${IMAGE_NAME}" \
       --build-arg "NVIDIA=${NVIDIA}" \
       --build-arg "DATE=${date}" \
       --tag "ghcr.io/ubiozur/${FULLNAME}" \
       ./src
    echo ""

# Make the ISO (Must be run in root/sudo)
[group('Build')]
[private]
_build-iso $date="":
    #!/usr/bin/env bash
    set -ueo pipefail
    # Make sure we have elevated priviledges
    if [[ "$EUID" != "0" && ! -v SUDO_COMMAND ]]; then
        echo -e "  \e[1;34mbuild-iso\e[0m  \e[1;31mERROR\e[0m  Must be run with \e[36melevated\e[0m priviledges"
        exit 1
    fi
    source .env
    [[ -z $date ]] && date=$(date --utc +%Y%m%d%H%M)
    [[ "${NVIDIA}" == "Y" ]] && VARIANT="-nvidia" || VARIANT=""
    readonly FULLNAME=${IMAGE_NAME,,}${VARIANT,,}

    echo -e "  \e[1;34mbuild-iso\e[0m  Building ISO"
    podman run --rm --privileged \
        --volume ./iso:/build-container-installer/build \
        --volume /var/lib/containers/storage:/var/lib/containers/storage \
        ghcr.io/jasonn3/build-container-installer:latest \
        VERSION="${BASE_VERSION}" \
        IMAGE_SIGNED=false \
        IMAGE_SRC="containers-storage:ghcr.io/ubiozur/${FULLNAME}:latest" \
        VARIANT="kinoite" \
        WEBUI=false \
        IMAGE_BASE="${IMAGE_NAME}"
    readonly ISO_NAME="${FULLNAME}-${date}.iso"
    echo -e "  \e[1;34mbuild-iso\e[0m  Changing name and permissions of the iso file \e[36m${ISO_NAME}\e[0m"
    mv iso/deploy.iso iso/${ISO_NAME}
    mv iso/deploy.iso-CHECKSUM iso/${ISO_NAME}-CHECKSUM
    chown ${USER}:${USER} iso/${ISO_NAME}*

# Build the image and create the ISO (Must be root/sudo)
[group('Build')]
build $date="":
    #!/usr/bin/env bash
    set -ueo pipefail
    # Make sure we have elevated priviledges
    if [[ "$EUID" != "0" && ! -v SUDO_COMMAND ]]; then
        echo -e "  \e[1;34mbuild\e[0m  \e[1;31mERROR\e[0m  Must be run with \e[36melevated\e[0m priviledges"
        exit 1
    fi
    [[ -z $date ]] && date=$(date --utc +%Y%m%d%H%M)
    echo -e "  \e[1;34mbuild\e[0m  Build date is \e[36m${date}\e[0m"
    # Build the image
    just _build-pod "${date}"
    # Build the ISO
    just _build-iso "${date}"

##
## Group to manage podman
##

# Clear and Delete all podman data (sudo and user)
[group('Podman')]
pod-reset:
    #!/usr/bin/env bash
    set -ueo pipefail
    echo -e "  \e[1;34mpod-reset\e[0m  Prune ALL \e[36mroot\e[0m images"
    sudo podman image prune -af
    echo -e "  \e[1;34mpod-reset\e[0m  Prune ALL \e[36mroot\e[0m system"
    sudo podman system prune -af
    echo -e "  \e[1;34mpod-reset\e[0m  Prune ALL \e[36m${USER}\e[0m images"
    podman image prune -af
    echo -e "  \e[1;34mpod-reset\e[0m  Prune ALL \e[36m${USER}\e[0m system"
    podman system prune -af
