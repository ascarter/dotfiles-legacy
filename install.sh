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
	if [ -n "${WSL_DISTRO_NAME}" ]; then
		echo "WSL environment"
		DISTRO_DESCRIPTION=$(lsb_release -d -s)
		case $(lsb_release -i -s) in
		Ubuntu )
			echo "Initializing WSL on ${DISTRO_DESCRIPTION}"
			# Update distro
			sudo apt update
			sudo apt upgrade -y

			# Install packages
			sudo apt install build-essential zsh keychain
			;;
		*) echo "Unknown Linux disto ${DISTRO_DESCRIPTION}" ;;
		esac

		# Install latest Go
		if ! command -v go >/dev/null 2>&1; then
			GO_PKG=https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz
			curl -L ${GO_PKG} | sudo tar -C /usr/local -xz
			sudo ln -s /usr/local/go/bin/go /usr/local/bin/go
			sudo ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt
		fi
		go version

		# Configure SSH
		for pubkey in /mnt/c/Users/${USER}/.ssh/id_*.pub; do
			privkey=$(dirname ${pubkey})/$(basename -s .pub ${pubkey})
			echo "chmod ${privkey}"
			chmod 0600 ${privkey}
		done

		# Configure WSL
		if ! [ -e /etc/wsl.conf ]; then
			echo "Generate WSL conf"
			sudo tee /etc/wsl.conf > /dev/null <<EOF
[automount]
enabled = true
options = "metadata"
EOF
		fi
		;;
	else
		case $(lsb_release -i -s) in
		Ubuntu )
			echo "Installing on $(lsb_release -d -s)"
			;;
		esac
	fi
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
if command -v zsh >/dev/null 2>&1; then
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
