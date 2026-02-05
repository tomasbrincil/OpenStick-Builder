#!/bin/sh -e

DEBIAN_FRONTEND=noninteractive
DEBCONF_NONINTERACTIVE_SEEN=true

echo 'tzdata tzdata/Areas select Etc' | debconf-set-selections
echo 'tzdata tzdata/Zones/Etc select UTC' | debconf-set-selections
echo "locales locales/default_environment_locale select en_US.UTF-8" | debconf-set-selections
echo "locales locales/locales_to_be_generated multiselect en_US.UTF-8 UTF-8" | debconf-set-selections
rm -f "/etc/locale.gen"

apt update -qqy
apt upgrade -qqy
apt autoremove -qqy
apt install -qqy --no-install-recommends \
    bridge-utils \
    dnsmasq \
    hostapd \
    iptables \
    locales \
    modemmanager \
    netcat-traditional \
    net-tools \
    network-manager \
    openssh-server \
    qrtr-tools \
    rmtfs \
    sudo \
    systemd-timesyncd \
    tzdata \
    wireguard-tools \
    wpasupplicant

# Detect which libconfig package is available and install it (if any).
# Do not abort the script if none are available.
set +e
CHOSEN_LIBCONFIG=""
for p in libconfig11 libconfig9 libconfig; do
    if apt-cache policy "$p" 2>/dev/null | grep -q 'Candidate:'; then
        CHOSEN_LIBCONFIG="$p"
        break
    fi
done

if [ -n "$CHOSEN_LIBCONFIG" ]; then
    apt install -qqy --no-install-recommends "$CHOSEN_LIBCONFIG"
else
    echo "Warning: no libconfig package found (libconfig11/libconfig9/libconfig)"
fi
set -e

apt clean
rm -rf /var/lib/apt/lists/*
    
apt clean
rm -rf /var/lib/apt/lists/*

passwd -d root

echo user:1::::/home/user:/bin/bash | newusers
echo 'user ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/user
