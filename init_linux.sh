#!/bin/sh
#
# Init script for Linux distribution
#
# Usage:
#	linux_init.sh
#

set -ue

# Install macOS requirements
if ! [ $(uname) = "Linux" ]; then
	echo "Linux distribution is required"
	exit 1
fi

DISTRO_DESCRIPTION=$(lsb_release -d -s)
echo "Installing requirements for ${DISTRO_DESCRIPTION}"

case $(lsb_release -i -s) in
Ubuntu )
	# Update distro
	sudo apt update
	sudo apt upgrade -y

	# Install packages
	sudo apt install build-essential zsh keychain
	;;
*)
	echo "Unknown Linux distro ${DISTRO_DESCRIPTION}"
	;;
esac
