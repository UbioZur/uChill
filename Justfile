## ~  UbioZur - https://github.com/UbioZur  ~ ##

export imageName := "uchill"
export fedoraVersion := "42"
export devRegistry := "localhost:5000"

##
## Group of commands to manage the just file
##

# List the available commands
[group('Justfile')]
list:
    @just --list

# Run check the Justfile
[group('Checks')]
[group('Justfile')]
just-check:
    #!/usr/bin/env bash
    echo -e "\e[1;34mJustfile\e[0m  Checking syntax"
    just --unstable --fmt --check -f Justfile

# Fix the Justfile syntax
[group('Justfile')]
just-fix:
    #!/usr/bin/env bash
    echo -e "\e[1;34mJustfile\e[0m  Fixing syntax"
    just --unstable --fmt -f Justfile
    echo -e "\e[1;34mJustfile\e[0m  Running checks on Justfile"
    just just-check

alias edit := just-edit

# Edit this Justfile
[group('Justfile')]
just-edit:
    #!/usr/bin/env bash
    $EDITOR Justfile
    just just-check

##
## Group of commands to manage scripts
##

alias script-check := scripts-check

# Run checks on scripts
[group('Checks')]
[group('Scripts')]
scripts-check:
    #!/usr/bin/env bash
    set -ueo pipefail
    exitCode=0
    echo -e "\e[1;34mScripts\e[0m  Checking Scripts"
    for file in $(find . | grep '^.**\.sh$'); do
        [[ -x "$file" ]] && continue
        exitCode=1
        echo -e "\e[1;34mScripts\e[0m  \e[1;31mERROR\e[0m  Need to be executable \e[36m${file}\e[0m"
    done
    echo -e "\e[1;34mScripts\e[0m  Checking githooks"
    for file in $(find ./githooks/*); do
        [[ -x "$file" ]] && continue
        exitCode=1
        echo -e "\e[1;34mScripts\e[0m  \e[1;31mERROR\e[0m  Need to be executable \e[36m${file}\e[0m"
    done
    exit $exitCode

alias script-fix := scripts-fix

# Fix Executable bit on scripts
[group('Scripts')]
scripts-fix:
    #!/usr/bin/env bash
    set -ueo pipefail
    echo -e "\e[1;34mScripts\e[0m  Fixing Scripts"
    for file in $(find . | grep '^.**\.sh$'); do
        [[ -x "$file" ]] && continue
        echo -e "\e[1;34mScripts\e[0m  Fixing \e[36m${file}\e[0m"
        chmod u+x ${file}
    done
    echo -e "\e[1;34mScripts\e[0m  Fixing githooks"
    for file in $(find ./githooks/*); do
        [[ -x "$file" ]] && continue
        echo -e "\e[1;34mScripts\e[0m  Fixing \e[36m${file}\e[0m"
        chmod u+x ${file}
    done
    echo -e "\e[1;34mScripts\e[0m  Running checks on scripts"
    just script-check

##
## Group of Git Commands
##

# Setup git hooks
[group('Git')]
git-hooks:
    #!/usr/bin/env bash
    set -ueo pipefail
    echo -e "\e[1;34mGit\e[0m  Setting up git hooks symlink"
    if [[ ! $(git status) ]]; then 
        echo -e "\e[1;34mGit\e[0m  \e[1;31mERROR\e[0m  It does not seem to be a git directory"
        exit 1
    fi
    for file in githooks/*; do
      ln -svf ../../"$file" .git/hooks/
    done
    #cp -vrs "githooks/*" ".git/hooks/"

##
## Group of Build Commands
##

alias build := pod-build

# Build the container
[group('Containers / Podman')]
pod-build:
    #!/usr/bin/env bash
    set -ueo pipefail
    source dev.env
    BUILD_ARGS=()
    BUILD_ARGS+=("--build-arg" "FEDORA_VERSION=${FEDORA_VERSION}")
    BUILD_ARGS+=("--build-arg" "DEBUG=${DEBUG:-0}")
    echo -e "\e[1;34mContainer\e[0m  Building Image \e[36m${devRegistry}/${IMAGE_NAME}\e[0m"
    podman build \
        "${BUILD_ARGS[@]}" \
        --disable-compression=false \
        --pull=newer \
        --tag "${devRegistry}/${IMAGE_NAME}" \
        ./src
    echo ""
    echo -e "\e[1;34mContainer\e[0m  List of images"
    podman images | grep ${IMAGE_NAME}

alias clean := pod-clean

# Remove ALL unused Images
[group('Containers / Podman')]
pod-clean:
    #!/usr/bin/env bash
    set -ueo pipefail
    echo -e "\e[1;34mContainer\e[0m  Cleaning dangling containers"
    podman image prune -f -a

alias iso := pod-iso

# Build an ISO
[group('Containers / Podman')]
pod-iso: pod-build
    #!/usr/bin/env bash
    set -ueo pipefail
    source dev.env
    readonly regFile="/etc/containers/registries.conf.d/001-localhost.conf"
    if [ ! -f ${regFile} ]; then
        echo -e "\e[1;34mContainer\e[0m  Creating the localhost registry configuration file \e[36m${regFile}\e[0m"
        echo -e '[[registry]]\nlocation = "{{ devRegistry }}"\ninsecure = true' | just _sudoif tee $regFile
        echo -e "\e[1;34mContainer\e[0m  Restarting Podman Service"
        just _sudoif systemctl restart podman
        sleep 2
    fi
    readonly podRegistry="registry"
    if ! podman container exists $podRegistry; then
        echo -e "\e[1;34mContainer\e[0m  Create and start local registry container"
        podman run -d -p 5000:5000 --name $podRegistry registry:2
        sleep 2
    fi
    readonly podStatus=$(podman inspect -f '{{{{.State.Status}}}}' $podRegistry)
    if [[ ! "$podStatus" == *"running"* ]]; then
        echo -e "\e[1;34mContainer\e[0m  Start local registry container"
        podman start $podRegistry
        sleep 2
    fi
    echo -e "\e[1;34mContainer\e[0m  Push to local registry"
    podman push ${devRegistry}/${IMAGE_NAME}
    echo -e "\e[1;34mContainer\e[0m  Pull from local registry"
    just _sudoif podman pull ${devRegistry}/${IMAGE_NAME}
    mkdir -p iso
    echo -e "\e[1;34mContainer\e[0m  Building the \e[36miso\e[0m"
    just _sudoif podman run --rm -it --privileged \
        --pull=newer --security-opt label=type:unconfined_t \
        -v ./iso:/output \
        -v /var/lib/containers/storage:/var/lib/containers/storage \
        -v ./src/iso.toml:/config.toml:ro \
        quay.io/centos-bootc/bootc-image-builder:latest \
        --type iso --chown 1000:1000 \
        ${devRegistry}/${IMAGE_NAME}:latest
    echo -e "\e[1;34mContainer\e[0m  Stop local registry container"
    podman stop $podRegistry
    echo -e "\e[1;34mContainer\e[0m  Renaming the  \e[36miso\e[0m"
    readonly name="${IMAGE_NAME}-${FEDORA_VERSION}-$(date +%Y%m%dT%H%M)"
    mv "./iso/bootiso/install.iso" "./iso/${name}.iso"
    mv "./iso/manifest-iso.json" "./iso/${name}-manifest.json"
    rm -Rf "./iso/bootiso"

##
## A Group of various checks
##

alias checks := check-quick

# Run quick check only
[group('Checks')]
check-quick: just-check scripts-check

alias checks-all := check-all

# Run all the checks
[group('Checks')]
check-all: just-check scripts-check

# Run all the fixes
[group('Checks')]
fix: just-fix scripts-fix

##
## Privates Functions
##

# Run a command as sudo if not root
[private]
_sudoif command *args:
    #!/usr/bin/env bash
    set -ueo pipefail
    if [[ "${UID}" -eq 0 ]]; then
        "$@"
    elif [[ "$(command -v sudo)" ]]; then
        /usr/bin/sudo {{ command }} {{ args }} || exit 1
    fi
