#!/bin/sh

#
# Install script for server
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
    sudo hostnamectl set-hostname "${input:-${hostname}}"
    sudo hostnamectl set-chassis server
    sudo hostnamectl set-icon-name ""

    # Update distro
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get autoremove -y

    # Install base packages
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common

    # Add Docker repository
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Add speedtest respository
    # https://www.speedtest.net/apps/cli
    curl -fsSL https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash

    # Update repositories
    sudo apt-get update

    # Install server packages
    sudo apt-get install -y \
      containerd.io \
      docker-ce \
      docker-ce-ci \
      docker-buildx-plugin \
      docker-compose-plugin \
      htop \
      jq \
      speedtest
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
