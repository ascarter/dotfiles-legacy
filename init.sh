#!/bin/sh
#
# Init script for Unix
#
# Usage:
#	init.sh [homebrew]
#
#	homebrew == destination for homebrew enlistment (default /opt/homebrew)
#

set -ue

case "$(uname)" in
Darwin )
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
	HOMEBREW="${1:-/opt/homebrew}"
	if ! [ -e ${HOMEBREW} ]; then
		echo "Install homebrew to ${HOMEBREW}"
		sudo mkdir -p ${HOMEBREW}
		sudo chown -R ${USER}:admin ${HOMEBREW}
		curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ${HOMEBREW}
	fi

	# Add homebrew extras tap
	${HOMEBREW}/bin/brew tap --full ascarter/extras
	;;
Linux )
	DISTRO_DESCRIPTION=$(lsb_release -d -s)
	echo "Installing requirements for ${DISTRO_DESCRIPTION}"

	case $(lsb_release -i -s) in
	Ubuntu )
		# Update distro
		sudo apt update
		sudo apt upgrade -y

		# Install packages
		sudo apt install build-essential git keychain libnss3-tools socat update-motd zsh
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
