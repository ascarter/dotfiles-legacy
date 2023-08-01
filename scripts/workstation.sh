#!/bin/sh

# Install workstation tools
# Recommend running developer.sh first

check_apt_repo() {
  apt-cache policy | grep ${1} > /dev/null
}

case "$(uname)" in
Darwin )
  echo "Installing macOS tools..."

  # TODO: brewfile with workstation apps and tools

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
    # Enable universe repositories
    # sudo add-apt-repository universe

    # Update software repositories
    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get autoremove -y

    # Useful CLI packages
    sudo apt-get install -y \
                apt-transport-https \
                ca-certificates \
                curl \
                dirmngr \
                duf \
                exa \
                gnupg \
                gnupg-agent \
                groff \
                libsecret-tools \
                mc \
                neofetch \
                software-properties-common \
                tmux \
                vim-gtk3 \
                xsel

    # Microsoft GPG key
    if ! [ -f /usr/share/keyrings/microsoft-archive-keyring.gpg ]; then
      curl https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg
    fi

    # Desktop Ubuntu (not WSL)
    if ! (grep -iq WSL2 /proc/version); then
      # Useful full Ubuntu applications
      sudo apt-get install -y \
                  dconf-editor \
                  fonts-firacode \
                  gnome-shell-extensions-gpaste \
                  gnome-system-log \
                  gnome-tweaks \
                  gpaste \
                  gparted \
                  openssh-server \
                  powertop

      # Microsoft Edge
      if ! check_apt_repo "https://packages.microsoft.com/repos/edge"; then
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list
        sudo apt-get update
      fi
      sudo apt-get install -y microsoft-edge-stable

      # Microsoft Teams
      if ! check_apt_repo "https://packages.microsoft.com/repos/ms-teams"; then
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/ms-teams stable main" | sudo tee /etc/apt/sources.list.d/teams.list
        sudo apt-get update
      fi
      sudo apt-get install -y teams

      # 1Password
      if ! check_apt_repo "https://downloads.1password.com"; then
        if ! [ -f /usr/share/keyrings/1password-archive-keyring.gpg ]; then
          curl -fsSL https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
        fi
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | sudo tee /etc/sources/apt.list.d/1password.list

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
      if ! check_apt_repo "https://updates.signal.org"; then
        curl -fsSL https://updates.signal.org/desktop/apt/keys.asc | sudo gpg --dearmor --output /usr/share/keyrings/signal-desktop-archive-keyring.gpg
        echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-archive-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' | sudo tee -a /etc/apt/sources.list.d/signal.list
        sudo apt-get update
      fi
      sudo apt-get install -y signal-desktop

      # Onedriver
      if ! check_apt_repo "https://download.opensuse.org/repositories/home:/jstaf"; then
        curl -fsSL https://download.opensuse.org/repositories/home:jstaf/xUbuntu_$(lsb_release -rs)/Release.key | sudo gpg --dearmor --output /usr/share/keyrings/jstaf-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/jstaf-archive-keyring.gpg] https://download.opensuse.org/repositories/home:/jstaf/xUbuntu_$(lsb_release -rs)/ /" | sudo tee /etc/apt/sources.list.d/jstaf.list
        sudo apt update
      fi
      sudo apt-get install -y onedriver
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

