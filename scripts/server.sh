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
  Ubuntu | Raspbian )
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

    # Add speedtest respository
    # https://www.speedtest.net/apps/cli
    curl -fsSL https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash

    # Update repositories
    sudo apt-get update

    # Install server packages
    sudo apt-get install -y htop jq speedtest
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
