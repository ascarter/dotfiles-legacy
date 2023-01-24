#!/bin/sh

# Install developer tools
#
# Usage:
#    developer.sh [-f]
#
#    Options:
#      -f   Force reinstall of keys and apt sources

force_reinstall=

while getopts f flag
do
  case $flag in
  f)  force_reinstall=1;;
  ?)  printf "Usage: %s: [-f]\n" $0
      exit 2;;
  esac
done

check_apt_repo() {
  [ -z "${force_reinstall}" ] && apt-cache policy | grep ${1} > /dev/null
}

case "$(uname)" in
Darwin )
  echo "Installing macOS tools..."

  # TODO: brewfile for developer tools

  # Enable PostgreSQL CLI
  if [ -d /Applications/Postgres.app ]; then
    sudo mkdir -p /etc/paths.d
    echo /Applications/Postgres.app/Contents/Versions/latest/bin | sudo tee /etc/paths.d/postgresapp
  fi

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
                gitg \
                gnupg \
                gnupg-agent \
                htop \
                jq \
                make \
                pass \
                python3 \
                python3-dev \
                python3-pip \
                socat

    # Microsoft GPG key
    if ! [ -f /usr/share/keyrings/microsoft-archive-keyring.gpg ]; then
      curl https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg
    fi

    # Microsoft package repo
    # https://docs.microsoft.com/en-us/windows-server/administration/linux-package-repository-for-microsoft-software
    #if ! check_apt_repo "https://packages.microsoft.com/ubuntu"; then
    #  echo "deb [arch=amd64,armhf,arm64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/ubuntu/20.04/prod focal main" | sudo tee /etc/apt/sources.list.d/microsoft-prod.list
    #  sudo apt-get update
    #fi
    # sudo apt-get install -y dotnet-sdk-6.0 powershell
    # sudo apt-get install -y msopenjdk-17

    # Azure CLI
    if ! check_apt_repo "https://packages.microsoft.com/repos/azure-cli"; then
      echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/azure-cli $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
      sudo apt-get update
    fi
    sudo apt-get install -y azure-cli

    # GitHub CLI
    # https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian-ubuntu-linux-apt
    if ! check_apt_repo "https://cli.github.com"; then
      curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
      sudo apt-get update
    fi
    sudo apt-get install -y gh

    # Node.js
    # https://github.com/nodesource/distributions/blob/master/README.md#installation-instructions
    if ! check_apt_repo "https://deb.nodesource.com"; then
      NODE_JS_VER=19
      curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/nodesource-archive-keyring.gpg
      echo "deb [signed-by=/usr/share/keyrings/nodesource-archive-keyring.gpg] https://deb.nodesource.com/node_${NODE_JS_VER}.x $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/nodesource.list
      echo "deb-src [signed-by=/usr/share/keyrings/nodesource-archive-keyring.gpg] https://deb.nodesource.com/node_${NODE_JS_VER}.x $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list.d/nodesource.list
      sudo apt-get update
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

    # Check if running under WSL
    if (grep -iq WSL2 /proc/version); then
      # Microsoft Visual Studio Code CLI
      VSCODE_CLI_OS=$(dpkg --print-architecture)
      [ $VSCODE_CLI_OS=amd64 ] && VSCODE_CLI_OS=x64
      curl -fsSL "https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-${VSCODE_CLI_OS}" | sudo tar -C /usr/local/bin -xz
    else
      # Install Git Credential Manager
      GCM_VERSION=$(curl -s https://api.github.com/repos/GitCredentialManager/git-credential-manager/releases/latest | jq -r '.tag_name' | sed 's/v//')
      if [ "$(dpkg --print-architecture)" = "amd64" ] ; then
        # Remove obsolete version
        if (dpkg-query --show gcmcore); then
          echo "Remove git-credential-manager-core"
          git-credential-manager-core unconfigure
          sudo dpkg -P gcmcore
        fi

        # Install latest GCM
        if ! (dpkg-query --show gcm) || [ $(git-credential-manager --version | cut -f1 -d'+') != ${GCM_VERSION} ]; then
          echo "Installing Git Credential Manager"
          curl -fsSL -o /tmp/gcm-linux_amd64.deb https://github.com/GitCredentialManager/git-credential-manager/releases/download/v${GCM_VERSION}/gcm-linux_amd64.${GCM_VERSION}.deb
          sudo dpkg -i /tmp/gcm-linux_amd64.deb
          rm -f /tmp/gcm-linux_amd64.deb
          git-credential-manager configure
        else
          echo "Git Credential Manager is latest"
        fi
      fi

      # Microsoft Visual Studio Code
      if ! check_apt_repo "https://packages.microsoft.com/repos/code"; then
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
        sudo apt-get update
      fi
      sudo apt-get install -y code

      # GitHub Desktop (Linux fork)
      # https://github.com/shiftkey/desktop
      if ! check_apt_repo "https://mirror.mwt.me/ghd/deb/"; then
        wget -qO - https://mirror.mwt.me/ghd/gpgkey | sudo tee /etc/apt/trusted.gpg.d/shiftkey-desktop.asc > /dev/null
        echo "deb [arch=$(dpkg --print-architecture)] https://mirror.mwt.me/ghd/deb/ any main" | sudo tee /etc/apt/sources.list.d/packagecloud-shiftkey-desktop.list
        sudo apt-get update
      fi
      sudo apt-get install -y github-desktop

      # Kubernetes
      # if ! check_apt_repo "https://apt.kubernetes.io"; then
      #   sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
      #   echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
      #   sudo apt-get update
      # fi
      # sudo apt-get install -y kubectl
    fi
    ;;
  esac
  ;;
esac
