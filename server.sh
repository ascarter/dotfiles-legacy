#!/bin/sh

#
# Init script for Unix server
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
        ARCH=$(dpkg --print-architecture)

        # Add speedtest respository
        # https://www.speedtest.net/apps/cli
        sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61
        echo "deb https://ookla.bintray.com/debian generic main" | sudo tee /etc/apt/sources.list.d/speedtest.list

        # Add Docker repository
        # https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo apt-key fingerprint 0EBFCD88
        sudo add-apt-repository "deb [arch=${ARCH}] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

		# Update distro
		sudo apt-get update
		sudo apt-get upgrade -y
        sudo apt-get autoremove -y

		# Install base packages
		sudo apt-get install -y apt-transport-https ca-certificates software-properties-common

        # Install server packages
        # Install developer packages
        sudo apt-get install -y \
            curl \
            containerd.io \
            docker-ce \
            docker-ce-cli \
            jq \
            speedtest

        # Add user to docker group
        sudo usermod -aG docker $USER
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
