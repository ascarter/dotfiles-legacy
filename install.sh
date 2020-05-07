#!/bin/sh
#
# Install script for dotfiles configuration
#
# Usage:
#	install.sh [target] [homedir] [homebrew]
#
# 	target   == destination for enlistment (default ~/.config/dotfiles)
#	homedir  == home directory (default ${HOME})
#	homebrew == destination for homebrew enlistment (default /opt/homebrew)
#

set -ue

DOTFILES="${1:-${HOME}/.config/dotfiles}"
HOMEDIR="${2:-${HOME}}"
RC_FILES=""

# Install platform requirements
case "$(uname)" in
Darwin )
	echo "Installing on $(sw_vers -productName) $(sw_vers -productVersion) ..."

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
	HOMEBREW="${3:-/opt/homebrew}"
	if ! [ -e ${HOMEBREW} ]; then
		echo "Install homebrew to ${HOMEBREW}"
		sudo mkdir -p ${HOMEBREW}
		sudo chown -R ${USER}:admin ${HOMEBREW}
		curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ${HOMEBREW}
	fi

	# Add Brewfile to RC files
	RC_FILES=${RC_FILES}" Brewfile"
	;;
Linux )
	DISTRO_DESCRIPTION=$(lsb_release -d -s)
	echo "Installing requirements for ${DISTRO_DESCRIPTION}"

	case $(lsb_release -i -s) in
	Ubuntu )
		# Update distro
		sudo apt update
		sudo apt upgrade -y

		# Install packages
		sudo apt install build-essential zsh keychain
		;;
	*)
		echo "Unknown Linux distro ${DISTRO_DESCRIPTION}"
		;;
	esac
	;;
esac

# Clone dotfiles
if ! [ -e ${DOTFILES} ]; then
	mkdir -p $(dirname ${DOTFILES})
	git clone https://github.com/ascarter/dotfiles ${DOTFILES}
fi

# Symlink rc files
mkdir -p ${HOMEDIR}
RC_FILES="$(cat ${DOTFILES}/rc.conf) "${RC_FILES}
for f in ${RC_FILES}; do
	source=${DOTFILES}/${f}
	target=${HOMEDIR}/.${f}
	if ! [ -e ${target} ]; then
		echo "Symlink ${source} -> ${target}"
		ln -s ${source} ${target}
	fi
done

# Configure zsh if installed
if command -v zsh &>/dev/null; then
	[ ${SHELL} != "/bin/zsh" ] && chsh -s /bin/zsh

	# Set zsh environment
	cat <<EOF > ${HOMEDIR}/.zshenv
DOTFILES=${DOTFILES}
EOF

	# Generate zsh completions
	zsh -c "${DOTFILES}/bin/mkcompletions"
else
	echo "zsh shell not installed"
fi

# Generates user's global gitconfig
${DOTFILES}/bin/gitconfig ${DOTFILES} ${HOMEDIR}/.gitconfig

echo "dotfiles installed."
