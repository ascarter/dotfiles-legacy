#!/bin/sh

# Install developer tools

check_apt_repo() {
  apt-cache policy | grep ${1} > /dev/null
}

case "$(uname)" in
Linux )
  echo "Installing $(lsb_release -d -s) $(uname -m) tools..."

  case $(lsb_release -i -s) in
  Ubuntu )
    # Ensure time is in sync (drift can occur on WSL or VM)
    sudo hwclock -s

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
                gnupg \
                gnupg-agent \
                groff \
                htop \
                jq \
                libnss3-tools \
                libsecret-tools \
                make \
                mc \
                nautilus \
                neofetch \
                python3 \
                python3-dev \
                python3-pip \
                socat \
                software-properties-common \
                tmux \
                update-motd \
                vim-gtk3 \
                xsel

    # Microsoft
    # https://docs.microsoft.com/en-us/windows-server/administration/linux-package-repository-for-microsoft-software
    # if ! check_apt_repo "https://packages.microsoft.com/ubuntu"; then
    #  curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc > /dev/null
    #  curl -fsSL https://packages.microsoft.com/config/ubuntu/$(lsb_release -r -s)/prod.list | sudo tee /etc/apt/sources.list.d/microsoft-prod.list
    #  sudo apt-get update
    # fi
    # sudo apt-get install -y dotnet-sdk-6.0 powershell
    # sudo apt-get install -y msopenjdk-17
  esac
esac
