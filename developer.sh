#!/bin/sh

check_repo() {
  apt-cache policy | grep ${1} > /dev/null
}

case "$(uname)" in
Darwin )
  echo "Installing macOS developer tools..."
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
                libsecret-tools \
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
      sudo apt-get install -y fonts-firacode gparted openssh-server ubuntu-restricted-extras ubuntu-restricted-addons

      # Docker
      if ! check_repo "https://download.docker.com"; then
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
      fi
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io

      # 1Password
      if ! check_repo "https://downloads.1password.com"; then
        if ! [ -f /usr/share/keyrings/1password-archive-keyring.gpg ]; then
          curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
        fi
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | sudo tee /etc/apt/sources.list.d/1password.list

        if ! [ -f /etc/debsig/policies/AC2D62742012EA22/1password.pol ]; then
          sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
          curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
        fi

        if ! [ -f /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg ]; then
          sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
          curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
        fi
        sudo apt-get update
      fi
      sudo apt-get install -y 1password 1password-cli
    fi

    # Add Pop packages
    if [ "$(lsb_release -i -s)" = "Pop" ]; then
      sudo apt-get install -y duf exa gnome-remote-desktop gnome-user-share
    else
      # Add Pop repositories
      sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 63C46DF0140D738961429F4E204DD8AEC33A7AFF
      if ! check_repo "https://apt.pop-os.org/proprietary"; then
        echo "deb https://apt.pop-os.org/proprietary $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/pop-os-proprietary.list > /dev/null
      fi
      if ! [ "$(lsb_release -cs)" = "focal" ] && ! check_repo "https://apt.pop-os.org/release"; then
        echo "deb https://apt.pop-os.org/release $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/pop-os-release.list > /dev/null
      fi
    fi

    # GitHub CLI
    # https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian-ubuntu-linux-apt
    if ! check_repo "https://cli.github.com"; then
      curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
      sudo apt-get update
    fi
    sudo apt-get install -y gh

    # GitHub Desktop (Linux fork)
    # https://github.com/shiftkey/desktop
    if ! check_repo "https://mirror.mwt.me/ghd/deb/"; then
      wget -qO - https://mirror.mwt.me/ghd/gpgkey | sudo tee /etc/apt/trusted.gpg.d/shiftkey-desktop.asc > /dev/null
      sudo sh -c 'echo "deb [arch=amd64] https://mirror.mwt.me/ghd/deb/ any main" > /etc/apt/sources.list.d/packagecloud-shiftkey-desktop.list'
      sudo apt-get update
    fi
    sudo apt-get install -y github-desktop

    # Microsoft
    # https://docs.microsoft.com/en-us/windows-server/administration/linux-package-repository-for-microsoft-software
    if ! check_repo "https://packages.microsoft.com/ubuntu"; then
      curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
      curl -sSL https://packages.microsoft.com/config/ubuntu/$(lsb_release -r -s)/prod.list | sudo tee /etc/apt/sources.list.d/microsoft-prod.list
      sudo apt-get update
    fi
    sudo apt-get install -y dotnet-sdk-6.0 msopenjdk-17 powershell

    # Node.js
    # https://github.com/nodesource/distributions/blob/master/README.md#debinstall
    if ! check_repo "https://deb.nodesource.com"; then
      curl -fsSL https://deb.nodesource.com/setup_17.x | sudo -E bash -
    fi
    sudo apt-get install -y nodejs

    # Yarn
    if ! check_repo "https://dl.yarnpkg.com"; then
      curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
      echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
      sudo apt-get update
    fi
    sudo apt-get install -y yarn
    sudo npm install --global typescript

    # Speedtest
    # https://www.speedtest.net/apps/cli
    if ! check_repo "https://install.speedtest.net"; then
      curl -s https://install.speedtest.net/app/cli/install.deb.sh | sudo bash
      sudo apt-get update
    fi
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
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path
    fi

    # Install Git Credential Manager for amd64
    if [ "$(dpkg --print-architecture)" = "amd64" ]; then
      echo "Installing Git Credential Manager"
      curl -L -o /tmp/gcmcore-linux_amd64.deb https://github.com/GitCredentialManager/git-credential-manager/releases/download/v2.0.632/gcmcore-linux_amd64.2.0.632.34631.deb
      sudo dpkg -i /tmp/gcmcore-linux_amd64.deb
      rm -f /tmp/gcmcore-linux_amd64.deb
    fi
    ;;
  esac
  ;;
esac
