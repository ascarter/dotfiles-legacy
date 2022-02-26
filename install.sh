#!/bin/sh
#
# Install script for dotfiles configuration
#
# Usage:
#	install.sh [home] [dotfiles]
#
#	home   == home directory (default ${HOME})
# 	target == destination for enlistment (default ~/.config/dotfiles)
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

	# Install Homebrew
	# HOMEBREW="${1:-/opt/brew}"
	# if ! [ -e ${HOMEBREW} ]; then
	# 	echo "Install homebrew to ${HOMEBREW}"
	# 	sudo mkdir -p ${HOMEBREW}
	# 	sudo chown -R ${USER}:admin ${HOMEBREW}
	# 	curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ${HOMEBREW}
	# fi

	# # Add homebrew extras tap
	# ${HOMEBREW}/bin/brew tap --full ascarter/extras

	# # Enable Git Credential Manager (.NET core)
	# brew tap microsoft/git
	# brew cask install git-credential-manager-core
	;;
Linux )
	DISTRO_DESCRIPTION=$(lsb_release -d -s)
	echo "Installing on ${DISTRO_DESCRIPTION}"

	case $(lsb_release -i -s) in
	Ubuntu )
		# Update distro
		sudo apt update
		sudo apt upgrade -y

		# Install packages
		sudo apt install -y apt-transport-https \
		                    build-essential \
							curl \
							git \
							update-motd \
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
