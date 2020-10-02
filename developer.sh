#!/bin/sh

case "$(uname)" in
Darwin )
    echo "Installing macOS developer tools..."

    # Developer tool installs via homebrew
    brew install muesli/tap/duf
    ;;
Linux )
    echo "Installing Linux developer tools..."

    case $(lsb_release -i -s) in
	Ubuntu )
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
        curl -sL https://deb.nodesource.com/setup_14.x | sudo -E sh -

        # Update repositories and packages
        sudo apt-get update
        sudo apt-get install -y apt-transport-https
        sudo apt-get update
        sudo apt-get upgrade -y

        # Install developer packages
        sudo apt-get install -y build-essential dotnet-sdk-3.1 gh git golang jq nodejs openjdk-14-jdk python3 python3-dev python3-pip

        # Install yarn support
        sudo npm install -g yarn

        # Install latest Go in ~/sdk/go1.x.y
        GO_VERSION=1.15.2
        if ! [ -x "$(command -v go${GO_VERSION})" ]; then
            go get golang.org/dl/go${GO_VERSION}
            go${GO_VERSION} download
        fi

        # Install duf tool
        go get -u github.com/muesli/duf
        ;;
    esac
    ;;
esac
