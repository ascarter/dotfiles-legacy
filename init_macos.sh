#!/bin/sh
#
# Init script for macOS
#
# Usage:
#	macos_init.sh [homebrew]
#
#	homebrew == destination for homebrew enlistment (default /opt/homebrew)
#

set -ue

HOMEBREW="${1:-/opt/homebrew}"

# Install macOS requirements
if ! [ $(uname) = "Darwin" ]; then
	echo "macOS is required"
	exit 1
fi

echo "Installing on $(sw_vers -productName) $(sw_vers -productVersion) ..."

# Verify Xcode installed
if ! [ -e /usr/bin/xcode-select ]; then
	echo "Xcode required. Install from macOS app store."
	open https://itunes.apple.com/us/app/xcode/id497799835?mt=12
	exit 1
fi

# Install Xcode command line tools
if ! [ -e /Library/Developer/CommandLineTools ]; then
	xcode-select --install
	read -p "Press any key to continue..." -n1 -s
	echo
	sudo xcodebuild -runFirstLaunch
fi

# Install Homebrew
if ! [ -e ${HOMEBREW} ]; then
	echo "Install homebrew to ${HOMEBREW}"
	sudo mkdir -p ${HOMEBREW}
	sudo chown -R ${USER}:admin ${HOMEBREW}
	curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ${HOMEBREW}
fi
