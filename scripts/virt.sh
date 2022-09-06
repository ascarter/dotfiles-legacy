#!/bin/sh

# Provision virtualization
#
# Usage:
#    virt.sh [-s]
#
#    Options:
#      -f   Force reinstall of keys and apt sources
#      -s   Enable server virtualization (default use desktop)

force_reinstall=
server_flag=

while getopts fs flag
do
  case $flag in
  f)  force_reinstall=1;;
  s)  server_flag=1;;
  ?)  printf "Usage: %s: [-s]\n" $0
      exit 2;;
  esac
done

check_apt_repo() {
  [ -z "${force_reinstall}" ] && apt-cache policy | grep ${1} > /dev/null
}

# Enable virtualisation

case "$(uname)" in
Darwin )
  echo "Enabling virtualisation for macOS"

  # TODO multipass install?

  ;;
Linux )
  echo "Enabling virtualisation for $(lsb_release -d -s) $(uname -m)"

  case $(lsb_release -i -s) in
  Ubuntu | Pop )
    # KVM/QEMU
    sudo apt-get install -y \
              bridge-utils \
              cpu-checker \
              libvirt-clients \
              libvirt-daemon \
              qemu qemu-kvm \
              virt-manager

    sudo kvm-ok

    # Docker
    if ! check_apt_repo "https://download.docker.com"; then
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
      sudo apt-get update
    fi

    if [ ! -z "${server_flag}" ]; then
      # Docker Engine for server
      echo "Installing Docker Engine"
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    else
      # Docker Desktop
      echo "Installing Docker Desktop"
      curl -fsSL -o /tmp/docker-desktop-amd64.deb https://desktop.docker.com/linux/main/amd64/docker-desktop-4.11.0-amd64.deb
      sudo apt-get install -y /tmp/docker-desktop-amd64.deb
      rm -f /tmp/docker-desktop-amd64.deb
    fi

    # Validate current $USER is enabled for docker group
    if ! (groups | grep docker > /dev/null); then
      echo "Add $USER to docker group by running the following:"
      echo "----"
      echo ""
      echo "sudo usermod -aG docker $USER"
      echo "newgrp docker"
    fi

    ;;
  esac
esac
