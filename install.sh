#!/bin/sh
#
# Install script for dotfiles configuration
#
# Usage:
# install.sh [home] [dotfiles]
#
#	home   == home directory (default ${HOME})
# target == destination for enlistment (default ~/.config/dotfiles)
#

set -ue

HOMEDIR="${1:-${HOME}}"
DOTFILES="${2:-${HOME}/.config/dotfiles}"

# Configure pre-requisites
case "$(uname)" in
Darwin )
  echo "Installing on $(sw_vers -productName) $(sw_vers -productVersion)"

  # Verify Xcode installed
  if ! [ -e /usr/bin/xcode-select ]; then
    echo "Xcode required. Install from macOS app store."
    open https://itunes.apple.com/us/app/xcode/id497799835?mt=12
    exit 1
  fi

  # Install Xcode command line tools
  if ! [ -e /Library/Developer/CommandLineTools ]; then
    xcode-select --install
    read -p "Press any key to continue..." -n1 -s
    echo
    sudo xcodebuild -runFirstLaunch
  fi

  # Install Rosetta 2 on M1
  if [ 'arm64' == $(uname -m) ]; then
    softwareupdate --install-rosetta
  fi

  # Install Homebrew (/opt/homebrew)
  if ! [ -e /opt/homebrew ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval $(/opt/homebrew/bin/brew shellenv)
  fi

  if [ -x "$(command -v brew)" ]; then
    # Add homebrew extras tap
    brew tap --full ascarter/extras

    # Enable Git Credential Manager (.NET core)
    # brew tap microsoft/git
    # brew install --cask git-credential-manager-core
  fi
  ;;
Linux )
  DISTRO_DESCRIPTION=$(lsb_release -d -s)
  echo "Installing on ${DISTRO_DESCRIPTION}"

  case $(lsb_release -i -s) in
  Ubuntu | Pop )
    # Update distro
    sudo apt update
    sudo apt upgrade -y

    # Install packages
    sudo apt install -y apt-transport-https \
                        build-essential \
                        curl \
                        git \
                        wget \
                        zip \
                        zsh
    ;;
  *)
    echo "Unknown Linux distro ${DISTRO_DESCRIPTION}"
    ;;
  esac
  ;;
*)
  echo "Unsupported platform"
  exit 1
  ;;
esac

# Clone dotfiles
if ! [ -e ${DOTFILES} ]; then
  mkdir -p $(dirname ${DOTFILES})
  git clone https://github.com/ascarter/dotfiles ${DOTFILES}
fi

# Symlink rc files
mkdir -p ${HOMEDIR}
for f in $(ls ${DOTFILES}/conf); do
  source=${DOTFILES}/conf/${f}
  target=${HOMEDIR}/.${f}
  if ! [ -e ${target} ]; then
    echo "Symlink ${source} -> ${target}"
    ln -s ${source} ${target}
  fi
done

# Configure zsh if installed
if [ -x "$(command -v zsh)" ]; then
  [ ${SHELL} != "/bin/zsh" ] && chsh -s /bin/zsh

  # Set zsh environment
  cat <<EOF > ${HOMEDIR}/.zshenv
DOTFILES=${DOTFILES}
EOF
else
  echo "zsh shell not installed"
fi

# Generate user's global gitconfig
${DOTFILES}/bin/gitconfig ${DOTFILES} ${HOMEDIR}/.gitconfig

# Ensure ssh directory exists
if ! [ -d ${HOMEDIR}/.ssh ]; then
  mkdir -p ${HOMEDIR}/.ssh
  chmod 0700 ${HOMEDIR}/.ssh
fi

echo "dotfiles installed"
echo "Reload session to apply configuration"
