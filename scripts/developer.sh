#!/bin/sh

# Install developer environment
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
  echo "Installing $(sw_vers -productName) $(sw_vers -productVersion) tools"

  # Install tools/apps from Homebrew
  echo "Install Homebrew packages"
  if ! brew bundle -q --global check; then
    brew bundle --global install
  fi

  # Enable PostgreSQL CLI
  if [ -d /Applications/Postgres.app ] && ! [ -f /etc/paths.d/postgresapp ]; then
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
                duf \
                exa \
                g++ \
                gcc \
                git \
                gitg \
                gnupg \
                gnupg-agent \
                groff \
                htop \
                jq \
                make \
                mc \
                neofetch \
                pass \
                tmux \
                vim-gtk3

    # Microsoft GPG key
    if ! [ -f /usr/share/keyrings/microsoft-archive-keyring.gpg ]; then
      curl https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg
    fi

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

    # Speedtest
    # https://www.speedtest.net/apps/cli
    if ! check_apt_repo "https://packagecloud.io/ookla/speedtest"; then
      curl -fsSL https://packagecloud.io/ookla/speedtest-cli/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/ookla_speedtest-cli-archive-keyring.gpg
      echo "deb [signed-by=/usr/share/keyrings/ookla_speedtest-cli-archive-keyring.gpg] https://packagecloud.io/ookla/speedtest-cli/ubuntu/ jammy main" | sudo tee /etc/apt/sources.list.d/ookla_speedtest-cli.list
      echo "deb-src [signed-by=/usr/share/keyrings/ookla_speedtest-cli-archive-keyring.gpg] https://packagecloud.io/ookla/speedtest-cli/ubuntu/ jammy main" | sudo tee -a /etc/apt/sources.list.d/ookla_speedtest-cli.list
      sudo apt-get update
    fi
    sudo apt-get install -y speedtest

    # Check if running under WSL
    if (grep -iq WSL2 /proc/version); then
        sudo apt-get install -y socat
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
    fi
    ;;
  esac
  ;;
esac
