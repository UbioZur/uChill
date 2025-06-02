<p align="center">
    <a href="https://github.com/UbioZur/uChill/actions/workflows/iso.yml" alt="Make uChill ISO">
        <img src="https://github.com/UbioZur/uChill/actions/workflows/iso.yml/badge.svg" /></a>
    <a href="https://github.com/UbioZur/uChill/actions/workflows/build.yml" alt="Build uChill Image">
        <img src="https://github.com/UbioZur/uChill/actions/workflows/build.yml/badge.svg" /></a>
    <!-- Badges from https://ghcr-badge.egpl.dev/ Color 16-166-203 -->
    <img src="https://ghcr-badge.egpl.dev/ubiozur/uchill/latest_tag?color=%2310a6cb&ignore=sha*.sig%2Clatest&label=tag&trim=" />
    <img src="https://ghcr-badge.egpl.dev/ubiozur/uchill/size?color=%2310a6cb&tag=latest&label=size&trim=" />
</p>

# uChill Atomic Desktop Minimal KDE

## Introduction

**uChill** is my custom Linux desktop, built on [Fedora](https://fedoraproject.org/atomic-desktops/) and [uBlue-os](https://universal-blue.org/). It's designed to be a clean and minimal base for the KDE Desktop, letting me add the applications I need using Flatpaks and other container technologies.

This setup also helps me learn about:

- **Building and sharing software in containers**
- **Automating development workflows** with GitHub Actions (CI/CD)
- **Streamlining command-line tasks** using Justfile

## Atomic Desktops

Linux Atomic Desktops signify a modern approach to computing where the core operating system is immutable, meaning it's read-only and remains consistent, unlike traditional systems that allow direct modification. Updates are applied transactionally, installing a new system image that can be seamlessly rolled back if issues occur, ensuring high reliability. Applications, meanwhile, are isolated in containers, enhancing security and preventing conflicts, all contributing to a more stable, predictable, and easily manageable desktop environment.

## Available Containers

- [ghcr.io/ubiozur/uchill](https://github.com/UbioZur/uChill/pkgs/container/uchill) Stable release of uChill.

## Base System

- Built on **Fedora 42**
- Uses [uBlue-os base-main](https://github.com/ublue-os/main) as the base image
- Minimal **KDE Plasma**
- **Signed** image

## Features

- `bat`, `fastfetch`, `lsd`, `micro`, `ripgrep`, `zoxide` and more
- Flathub
- Kitty Terminal
- Podman, Distrobox and Toolbox
- Waydroid

## Bootc commands

- To **Switch to uChill** from an existing Atomic / uBlue image

```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/ubiozur/uchill:latest
```

- To **check** if an upgrade is available

```bash
sudo bootc upgrade --check
```

- To apply an **upgrade**

```bash
sudo bootc upgrade ---apply
```

- To **rollback** to the previous image

```bash
sudo bootc rollback
```
