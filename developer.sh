#!/bin/sh

case "$(uname)" in
Darwin )
    echo "Installing macOS developer tools..."

    # Install duf tool
    go get -u github.com/muesli/duf
    ;;
Linux )
    echo "$(lsb_release -d -s) ($(uname -o) $(uname -r) $(uname -m))"
    echo "Updating developer tools..."

    case $(lsb_release -i -s) in
	Ubuntu )
        ARCH=$(dpkg --print-architecture)

        # Ensure time is in sync (drift can occur on WSL or VM)
        sudo hwclock -s

        # Setup base packages
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates dirmngr software-properties-common

        # Add GitHub CLI repository
        # https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian-ubuntu-linux-apt
        sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
        sudo apt-add-repository https://cli.github.com/packages

        # Add Microsoft repository
        # https://docs.microsoft.com/en-us/windows-server/administration/linux-package-repository-for-microsoft-software#ubuntu
        curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
        sudo apt-add-repository https://packages.microsoft.com/ubuntu/20.04/prod

        # Add nodesource repository
        # https://github.com/nodesource/distributions/blob/master/README.md#debinstall
        curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -

        # Add speedtest respository
        # https://www.speedtest.net/apps/cli
		curl -s https://install.speedtest.net/app/cli/install.deb.sh | sudo -E bash -

        # Enable universe repositories
        sudo add-apt-repository universe

        # Update repositories and packages
        sudo apt-get update
        sudo apt-get upgrade -y
        sudo apt-get autoremove -y

        # Install developer packages
        sudo apt-get install -y \
            build-essential \
            curl \
            dotnet-sdk-5.0 \
            gh \
            git \
            gnupg \
            gnupg-agent \
            jq \
            mc \
            msopenjdk-11 \
            nodejs \
            powershell \
            python3 \
            python3-dev \
            python3-pip \
            speedtest

        # Update npm and install yarn support
        sudo npm install -g npm yarn

        # Install Go in /usr/local
        GO_VERSION=1.16.6
        if [ -d /usr/local/go ] && [ "$(/usr/local/go/bin/go version | cut -f3 -d' ')" != "go${GO_VERSION}" ]; then
            echo Removing $(/usr/local/go/bin/go version) ...
            sudo rm -Rf /usr/local/go
        fi

        if ! [ -d /usr/local/go ]; then
            echo Install Go ${GO_VERSION}...
            curl -sL https://golang.org/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz | sudo tar -C /usr/local -xz
            /usr/local/go/bin/go version
        fi

        # Install duf tool
        /usr/local/go/bin/go get -u github.com/muesli/duf

        # Add Docker (except on WSL)
        if [ -z "${WSL_DISTRO_NAME}" ]; then
            # Add Docker repository
            # https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
            sudo apt-key fingerprint 0EBFCD88
            sudo add-apt-repository "deb [arch=${ARCH}] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

            # Install Docker
            sudo apt-get update
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io

            # Add user to docker group
            sudo usermod -aG docker $USER
        fi
        ;;
    esac
    ;;
esac
