#!/bin/sh

# Install developer tools

check_apt_repo() {
  apt-cache policy | grep ${1} > /dev/null
}

case "$(uname)" in
Darwin )
  echo "Installing macOS tools..."

  # TODO: brewfile for developer tools

  ;;
Linux )
  echo "Installing $(lsb_release -d -s) $(uname -m) tools..."

  case $(lsb_release -i -s) in
  Ubuntu | Pop )
    # Update software repositories
    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get autoremove -y

    # Setup common base packages
    sudo apt-get install -y \
                apt-transport-https \
                build-essential \
                ca-certificates \
                curl \
                dirmngr \
                g++ \
                gcc \
                git \
                gnupg \
                gnupg-agent \
                htop \
                jq \
                make \
                python3 \
                python3-dev \
                python3-pip

    # Microsoft
    # https://docs.microsoft.com/en-us/windows-server/administration/linux-package-repository-for-microsoft-software
    # if ! check_apt_repo "https://packages.microsoft.com/ubuntu"; then
    #  curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc > /dev/null
    #  curl -fsSL https://packages.microsoft.com/config/ubuntu/$(lsb_release -r -s)/prod.list | sudo tee /etc/apt/sources.list.d/microsoft-prod.list
    #  sudo apt-get update
    # fi
    # sudo apt-get install -y dotnet-sdk-6.0 powershell
    # sudo apt-get install -y msopenjdk-17

    # Microsoft Visual Studio Code
    # if ! check_apt_repo "https://packages.microsoft.com/repos/code"; then
    #  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft.gpg] http://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    #  sudo apt-get update
    # fi
    # sudo apt-get install -y code

    # GitHub Desktop (Linux fork)
    # https://github.com/shiftkey/desktop
    if ! check_apt_repo "https://mirror.mwt.me/ghd/deb/"; then
      wget -qO - https://mirror.mwt.me/ghd/gpgkey | sudo tee /etc/apt/trusted.gpg.d/shiftkey-desktop.asc > /dev/null
      echo "deb [arch=$(dpkg --print-architecture)] https://mirror.mwt.me/ghd/deb/ any main" | sudo tee /etc/apt/sources.list.d/packagecloud-shiftkey-desktop.list
      sudo apt-get update
    fi
    sudo apt-get install -y github-desktop
  fi

    # GitHub CLI
    # https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian-ubuntu-linux-apt
    if ! check_apt_repo "https://cli.github.com"; then
      curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
      sudo apt-get update
    fi
    sudo apt-get install -y gh

    # Install Git Credential Manager for amd64
    if [ "$(dpkg --print-architecture)" = "amd64" ]; then
      echo "Installing Git Credential Manager"
      curl -fsSL -o /tmp/gcmcore-linux_amd64.deb https://github.com/GitCredentialManager/git-credential-manager/releases/download/v2.0.632/gcmcore-linux_amd64.2.0.632.34631.deb
      sudo dpkg -i /tmp/gcmcore-linux_amd64.deb
      rm -f /tmp/gcmcore-linux_amd64.deb
    fi

    # Node.js
    # https://github.com/nodesource/distributions/blob/master/README.md#debinstall
    # Use impish as latest
    if ! check_apt_repo "https://deb.nodesource.com"; then
      curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | gpg --dearmor | sudo tee /usr/share/keyrings/nodesource-archive-keyring.gpg > /dev/null
      echo "deb [signed-by=/usr/share/keyrings/nodesource-archive-keyring.gpg] https://deb.nodesource.com/node_18.x impish main" | sudo tee /etc/apt/sources.list.d/nodesource.list
      echo "deb-src [signed-by=/usr/share/keyrings/nodesource-archive-keyring.gpg] https://deb.nodesource.com/node_18.x impish main" | sudo tee -a /etc/apt/sources.list.d/nodesource.list
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
    ;;
  esac
  ;;
esac
