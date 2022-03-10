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
    Ubuntu | Pop )
        # Ensure time is in sync (drift can occur on WSL or VM)
        sudo hwclock -s

        # Enable universe repositories
        sudo add-apt-repository universe

        # Setup base packages
        sudo apt-get update
        sudo apt-get upgrade
        sudo apt-get autoremove -y
        sudo apt-get install -y apt-transport-https \
                                ca-certificates \
                                build-essential \
                                curl \
                                dirmngr \
                                ffmpeg \
                                g++ \
                                gcc \
                                git \
                                gnome-tweaks \
                                gnupg \
                                gnupg-agent \
                                htop \
                                jq \
                                lsb-release \
                                make \
                                mc \
                                python3 \
                                python3-dev \
                                python3-pip \
                                software-properties-common \
								tmux \
                                vim-gtk3

		if [ -n "${WSL_DISTRO_NAME}" ]; then
	        # WSL extras
        	sudo apt-get install -y keychain libnss3-tools nautilus socat update-motd
		else
			# Full Ubuntu/Pop install
			sudo apt-get install -y gparted openssh-server ubuntu-restricted-extras ubuntu-restricted-addons

            # Docker
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt-get update
            sudo apt-get install docker-ce docker-ce-cli containerd.io

			# 1Password
			if ! [ -f /usr/share/keyrings/1password-archive-keyring.gpg ]; then
				curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
			fi
			echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list
			if ! [ -f /etc/debsig/policies/AC2D62742012EA22/1password.pol ]; then
				sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
				curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
			fi
			if ! [ -f /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg ]; then
				sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
				curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
			fi
			sudo apt-get update
			sudo apt-get install -y 1password
		fi

		# Add Pop packages
        if [ "$(lsb_release -i -s)" = "Pop" ]; then
            sudo apt-get install -y duf exa gnome-remote-desktop gnome-user-share
        fi

        # GitHub CLI
        # https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian-ubuntu-linux-apt
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y gh

        # Microsoft
        # https://docs.microsoft.com/en-us/windows-server/administration/linux-package-repository-for-microsoft-software#ubuntu
        curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
        # sudo apt-add-repository https://packages.microsoft.com/ubuntu/$(lsb_release -r -s)/prod
        # Pin to 20.04 until next LTS
		sudo apt-add-repository https://packages.microsoft.com/ubuntu/20.04/prod
        sudo apt-get update
        sudo apt-get install -y dotnet-sdk-6.0 msopenjdk-17 powershell

        # Node.js
        # https://github.com/nodesource/distributions/blob/master/README.md#debinstall
        curl -fsSL https://deb.nodesource.com/setup_17.x | sudo -E bash -

        # Yarn
        curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
        echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
        sudo apt-get update
        sudo apt-get install -y nodejs yarn
        sudo npm install --global typescript

        # Speedtest
        # https://www.speedtest.net/apps/cli
        curl -s https://install.speedtest.net/app/cli/install.deb.sh | sudo bash
        sudo apt-get update
        sudo apt-get install -y speedtest

        # Go
        GO_VERSION=$(curl -s "https://go.dev/dl/?mode=json" | jq --arg os $(uname -s | tr '[:upper:]' '[:lower:]') --arg arch $(dpkg --print-architecture) -r '[.[0].files[] | select(.os == $os and .arch == $arch)| .version] | unique | .[]')
        if [ -d /usr/local/go ] && [ "$(/usr/local/go/bin/go version | cut -f3 -d' ')" != "${GO_VERSION}" ]; then
            echo Removing $(/usr/local/go/bin/go version) ...
            sudo rm -Rf /usr/local/go
        fi

        if ! [ -d /usr/local/go ]; then
            echo Install Go ${GO_VERSION}...
            curl -sL https://golang.org/dl/${GO_VERSION}.linux-$(dpkg --print-architecture).tar.gz | sudo tar -C /usr/local -xz
            /usr/local/go/bin/go version
        fi

		# Rust
        if [ -x "$(command -v rustup)" ]; then
            echo "Updating rust"
            rustup update
        else
		    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        fi
        ;;
    esac
    ;;
esac
