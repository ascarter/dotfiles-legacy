#!/bin/sh

#
# Init script for Unix server
# Tested for Raspberry Pi 3+ on Ubuntu 20.04+
#
# Usage:
#	server.sh
#

set -ue

case "$(uname)" in
Linux )
  DISTRO_DESCRIPTION=$(lsb_release -d -s)
  echo "Installing server packages for ${DISTRO_DESCRIPTION}"

  case $(lsb_release -i -s) in
  Ubuntu )
    # Configure hostname
    hostname="$(hostname -s)"
    read -p "hostname (${hostname}): " input
    sudo hostnamectl set-hostname "${input:-${current}}"
    sudo hostnamectl set-chassis server
    sudo hostnamectl set-icon-name ""

    # Update distro
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get autoremove -y

    # Install base packages
    sudo apt-get install -y apt-transport-https ca-certificates software-properties-common

    # Add Docker repository
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Add speedtest respository
    # https://www.speedtest.net/apps/cli
    curl -fsSL https://install.speedtest.net/app/cli/install.deb.sh | sudo bash

    # Install server packages
    # Install developer packages
    sudo apt-get install -y \
      curl \
      containerd.io \
      docker-ce \
      docker-ce-cli \
      jq \
      speedtest

    # Install docker-compose
    sudo curl -fsSL "https://github.com/docker/compose/releases/download/v2.2.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    ;;
  *)
    echo "Unknown Linux distro ${DISTRO_DESCRIPTION}"
    ;;
  esac
  ;;
*)
  echo "Unsupported platform"
  exit 1
  ;;
esac
