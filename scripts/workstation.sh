#!/bin/sh

# Install developer tools

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

    # Setup common base packages
    sudo apt-get install -y \
                alpine \
                alpine-doc \
                alpine-pico \
                apt-transport-https \
                ca-certificates \
                curl \
                dconf-editor \
                default-mta \
                dirmngr \
                ffmpeg \
                fonts-firacode \
                gnome-shell-extensions-gpaste \
                gnome-system-log \
                gnome-tweaks \
                gnupg \
                gnupg-agent \
                gpaste \
                gparted \
                groff \
                imagemagick \
                libsecret-tools \
                mc \
                neofetch \
                openssh-server \
                software-properties-common \
                tmux \
                ubuntu-restricted-extras \
                ubuntu-restricted-addons \
                vim-gtk3 \
                xsel

    # Newer common base packages (post-focal)
    if ! [ "$(lsb_release -cs)" = "focal" ]; then
      sudo apt-get install -y \
                  duf \
                  exa
    fi

    # Microsoft GPG key
    if ! [ -f /usr/share/keyrings/microsoft-archive-keyring.gpg ]; then
      curl https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg
    fi

    # Microsoft Edge
    if ! check_apt_repo "https://packages.microsoft.com/repos/edge"; then
      curl https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg
      echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list
      sudo apt-get update
    fi
    sudo apt-get install -y microsoft-edge-stable

    # 1Password
    if ! check_apt_repo "https://downloads.1password.com"; then
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

    # Speedtest
    # https://www.speedtest.net/apps/cli
    # Use groovy as latest
    if ! check_apt_repo "https://install.speedtest.net"; then
      curl -fsSL https://packagecloud.io/ookla/speedtest-cli/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/ookla_speedtest-cli-archive-keyring.gpg > /dev/null
      curl -fsSL "https://packagecloud.io/install/repositories/ookla/speedtest-cli/config_file.list?os=Ubuntu&dist=groovy&source=script" | sudo tee /etc/apt/sources.list.d/ookla_speedtest-cli.list
      sudo apt-get update
    fi
    sudo apt-get install -y speedtest
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

