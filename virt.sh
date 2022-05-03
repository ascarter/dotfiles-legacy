#!/bin/sh

# Enable virtualisation

check_apt_repo() {
  apt-cache policy | grep ${1} > /dev/null
}

case "$(uname)" in
Darwin )
  echo "Enabling virtualisation for macOS"

  # TODO

  ;;
Linux )
  echo "Enabling virtualisation for $(lsb_release -d -s) $(uname -m)"

  case $(lsb_release -i -s) in
  Ubuntu | Pop )
    # Docker
    if ! check_apt_repo "https://download.docker.com"; then
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
      sudo apt-get update
    fi
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    if ! (groups | grep docker); then
      echo "Add $USER to docker group"
      sudo usermod -aG docker $USER
      echo "Logout or execute `newgrp docker`"
    fi

    # KVM
    sudo apt-get install -y \
              bridge-utils \
              cpu-checker \
              libvirt-clients \
              libvirt-daemon \
              qemu qemu-kvm \
              virt-manager

    sudo kvm-ok
    ;;
  esac
esac
