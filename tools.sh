#!/bin/sh

check_repo() {
  apt-cache policy | grep ${1} > /dev/null
}

add_gpg_key() {
  local keyring=/usr/share/keyrings/${1}-archive-keyring.gpg

  if ! [ -f ${keyring} ]; then
    local dl_keyring=$(mktemp)
    gpg --no-default-keyring --keyring ${dl_keyring} --keyserver keyserver.ubuntu.com --recv-keys ${2}
    sudo mv ${dl_keyring} ${keyring}
  else
    echo "Keyring ${keyring} already exists"
  fi
}

case "$(uname)" in
Darwin )
  echo "Installing macOS tools..."

  # Symlink 1Password agent
  if [ -S ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock ] && ! [ -S ~/.1password/agent.sock ]; then
    echo "Enabling 1Password SSH Agent..."
  	mkdir -p ~/.1password
    ln -s ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock ~/.1password/agent.sock
  fi

  ;;
Linux )
  echo "Installing $(lsb_release -d -s) $(uname -m) tools..."

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
    sudo apt-get install -y \
                alpine \
                alpine-doc \
                alpine-pico \
                apt-transport-https \
                ca-certificates \
                build-essential \
                curl \
                default-mta \
                dirmngr \
                ffmpeg \
                fonts-firacode \
                g++ \
                gcc \
                git \
                gnome-remote-desktop \
                gnome-shell-extensions-gpaste \
                gnome-system-log \
                gnome-tweaks \
                gnome-user-share \
                gnupg \
                gnupg-agent \
                gpaste \
                gparted \
                htop \
                imagemagick \
                jq \
                libsecret-tools \
                lsb-release \
                make \
                mc \
                neofetch \
                openssh-server \
                python3 \
                python3-dev \
                python3-pip \
                software-properties-common \
                tmux \
                vim-gtk3 \
                xsel

    # Newer apps and tools (post-Focal)
    if ! [ "$(lsb_release -cs)" = "focal" ]; then
      sudo apt-get install -y
                    duf \
                    exa
    fi

    # Microsoft
    # https://docs.microsoft.com/en-us/windows-server/administration/linux-package-repository-for-microsoft-software
    if ! check_repo "https://packages.microsoft.com/ubuntu"; then
      curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc > /dev/null
      curl -fsSL https://packages.microsoft.com/config/ubuntu/$(lsb_release -r -s)/prod.list | sudo tee /etc/apt/sources.list.d/microsoft-prod.list
      sudo apt-get update
    fi
    # sudo apt-get install -y dotnet-sdk-6.0 powershell
    # sudo apt-get install -y msopenjdk-17

    if [ -n "${WSL_DISTRO_NAME}" ]; then
      # WSL extras
      sudo apt-get install -y libnss3-tools nautilus socat update-motd
    else
      # Microsoft Visual Studio Code
      if ! check_repo "https://packages.microsoft.com/repos/code"; then
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft.gpg] http://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
        sudo apt-get update
      fi
      sudo apt-get install -y code

      # Microsoft Edge
      if ! check_repo "https://packages.microsoft.com/repos/edge"; then
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list
        sudo apt-get update
      fi
      # sudo apt-get install microsoft-edge

      # Docker
      if ! check_repo "https://download.docker.com"; then
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
        sudo apt-get update
      fi
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io
      if ! (groups | grep docker); then
        echo "Add $USER to docker group"
        sudo usermod -aG docker $USER
        newgrp docker
      fi

      # 1Password
      if ! check_repo "https://downloads.1password.com"; then
        if ! [ -f /usr/share/keyrings/1password-archive-keyring.gpg ]; then
          curl -fsSL https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
        fi
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | sudo tee /etc/apt/sources.list.d/1password.list

        if ! [ -f /etc/debsig/policies/AC2D62742012EA22/1password.pol ]; then
          sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
          curl -fsSL https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
        fi

        if ! [ -f /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg ]; then
          sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
          curl -fsSL https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
        fi
        sudo apt-get update
      fi
      sudo apt-get install -y 1password 1password-cli

      # Signal
      if ! check_repo "https://updates.signal.org"; then
        curl -fsSL https://updates.signal.org/desktop/apt/keys.asc | sudo gpg --dearmor --output /usr/share/keyrings/signal-desktop-archive-keyring.gpg
        echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-archive-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' | sudo tee -a /etc/apt/sources.list.d/signal.list
        sudo apt-get update
      fi
      sudo apt install -y signal-desktop

      # GitHub Desktop (Linux fork)
      # https://github.com/shiftkey/desktop
      if ! check_repo "https://mirror.mwt.me/ghd/deb/"; then
        wget -qO - https://mirror.mwt.me/ghd/gpgkey | sudo tee /etc/apt/trusted.gpg.d/shiftkey-desktop.asc > /dev/null
        echo "deb [arch=$(dpkg --print-architecture)] https://mirror.mwt.me/ghd/deb/ any main" | sudo tee /etc/apt/sources.list.d/packagecloud-shiftkey-desktop.list
        sudo apt-get update
      fi
      sudo apt-get install -y github-desktop
    fi

    # GitHub CLI
    # https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian-ubuntu-linux-apt
    if ! check_repo "https://cli.github.com"; then
      curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
      sudo apt-get update
    fi
    sudo apt-get install -y gh

    # Speedtest
    # https://www.speedtest.net/apps/cli
    if ! check_repo "https://install.speedtest.net"; then
      curl -fsSL https://packagecloud.io/ookla/speedtest-cli/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/ookla_speedtest-cli-archive-keyring.gpg > /dev/null
      curl -fsSL "https://packagecloud.io/install/repositories/ookla/speedtest-cli/config_file.list?os=Ubuntu&dist=$(lsb_release -cs)&source=script" | sudo tee /etc/apt/sources.list.d/ookla_speedtest-cli.list
      sudo apt-get update
    fi
    sudo apt-get install -y speedtest

    # Node.js
    # https://github.com/nodesource/distributions/blob/master/README.md#debinstall
    if ! check_repo "https://deb.nodesource.com"; then
      curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | gpg --dearmor | sudo tee /usr/share/keyrings/nodesource-archive-keyring.gpg > /dev/null
      echo "deb [signed-by=/usr/share/keyrings/nodesource-archive-keyring.gpg] https://deb.nodesource.com/node_18.x $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/nodesource.list
      echo "deb-src [signed-by=/usr/share/keyrings/nodesource-archive-keyring.gpg] https://deb.nodesource.com/node_18.x $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/nodesource.list
    fi
    sudo apt-get install -y nodejs

    # Go
    GO_VERSION=$(curl -fsSL "https://go.dev/dl/?mode=json" | jq --arg os $(uname -s | tr '[:upper:]' '[:lower:]') --arg arch $(dpkg --print-architecture) -r '[.[0].files[] | select(.os == $os and .arch == $arch)| .version] | unique | .[]')
    if [ -d /usr/local/go ] && [ "$(/usr/local/go/bin/go version | cut -f3 -d' ')" != "${GO_VERSION}" ]; then
      echo Removing $(/usr/local/go/bin/go version) ...
      sudo rm -Rf /usr/local/go
    fi

    if ! [ -d /usr/local/go ]; then
      echo Install Go ${GO_VERSION}...
      curl -fsSL https://golang.org/dl/${GO_VERSION}.linux-$(dpkg --print-architecture).tar.gz | sudo tar -C /usr/local -xz
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
      curl -fsSL -o /tmp/gcmcore-linux_amd64.deb https://github.com/GitCredentialManager/git-credential-manager/releases/download/v2.0.632/gcmcore-linux_amd64.2.0.632.34631.deb
      sudo dpkg -i /tmp/gcmcore-linux_amd64.deb
      rm -f /tmp/gcmcore-linux_amd64.deb
    fi
    ;;
  esac
  ;;
esac

if [ -S ~/.1password/agent.sock ]; then
  # TODO: add 1Password SSH Agent to ~/.ssh/config
  echo "Add following to ~/.ssh/config:"
  echo "  Host *"
  echo "      IdentityAgent ~/.1password/agent.sock"
fi

