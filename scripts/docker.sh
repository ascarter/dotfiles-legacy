#!/bin/sh

# Provision docker engine
#
# Usage:
#    docker.sh [-s]
#
#    Options:
#      -f   Force reinstall of keys and apt sources
#      -s   Server install (docker engine)

force_reinstall=

while getopts fs flag
do
  case $flag in
  f)  force_reinstall=1;;
  s)  server_flag=1;;
  ?)  printf "Usage: %s: [-s][-f]\n" $0
      exit 2;;
  esac
done

check_apt_repo() {
  [ -z "${force_reinstall}" ] && apt-cache policy | grep ${1} > /dev/null
}

case "$(uname)" in
Darwin )
  # TODO install docker desktop
  ;;
Linux )
  echo "Enabling Docker for $(lsb_release -d -s) $(uname -m)"

  case $(lsb_release -i -s) in
  Ubuntu | Pop )
    if ! check_apt_repo "https://download.docker.com"; then
      # Add Docker repository
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt-get update
    fi

    if [ ! -z "${server_flag}" ]; then
      # Docker Engine for server
      echo "Installing Docker Engine"
      sudo apt-get install -y containerd.io docker-ce docker-ce-cli docker-buildx-plugin docker-compose-plugin
    else
      # Docker Desktop
      echo "Installing Docker Desktop"
      DOCKER_VERSION="4.16.2"
      curl -fsSL -o /tmp/docker-desktop-amd64.deb https://desktop.docker.com/linux/main/amd64/docker-desktop-${DOCKER_VERSION}-amd64.deb
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
