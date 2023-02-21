#!/bin/sh

# Provision virtualization
#
# Usage:
#    virt.sh [-s]
#
#    Options:
#      -f   Force reinstall of keys and apt sources

force_reinstall=
server_flag=

while getopts fs flag
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
    ;;
  esac
esac
