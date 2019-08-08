#!/bin/sh

set -ueo pipefail

#
# Install script for dotfiles configuration
#
# Usage:
#	install [dotfiles] [homebrew]
#
# Defaults:
#	dotfiles == ~/.config/dotfiles
#	homebrew == /opt/homebrew
#

DOTFILES=${1:-${HOME}/.config/dotfiles}
HOMEBREW_ROOT=${2:-/opt/homebrew}

# Install platform requirements
case $(uname) in
Darwin )
	# Verify Xcode installed
	if ! [ -e /usr/bin/xcode-select ]; then
		echo "Xcode required. Install from macOS app store."
    		open https://itunes.apple.com/us/app/xcode/id497799835?mt=12
    		exit 1
	fi
	
	# Install Xcode command line tools
	if ! [ -e /Library/Developer/CommandLineTools ]; then
		xcode-select --install
	fi
	
	# Install Homebrew
	if ! [ -e ${HOMEBREW_ROOT} ]; then
		echo "Install homebrew to ${HOMEBREW_ROOT}"
		sudo mkdir -p ${HOMEBREW_ROOT}
		sudo chown -R ${USER}:admin ${HOMEBREW_ROOT}
		curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ${HOMEBREW_ROOT}
	fi
	;;
Linux )
	;;
esac

# Clone dotfiles
if ! [ -e ${DOTFILES} ]; then
	mkdir -p $(dirname ${DOTFILES})
	git clone https://github.com/ascarter/dotfiles ${DOTFILES}
fi

# Symlink home directory files
for source in ${DOTFILES}/home/*; do
	filename=$(basename ${source})
	target=${HOME}/.${filename}
	if ! [ -e ${target} ]; then
		echo "Symlink ${source} -> ${target}"
		ln -s ${source} ${target}
	fi
done

# Change shell to zsh
[ ${SHELL} != "/bin/zsh" ] && chsh -s /bin/zsh

# Set zsh configuration
cat <<EOF > ${HOME}/.zshenv
ZDOTDIR=${DOTFILES}/zsh
DOTFILES=${DOTFILES}
EOF

# Generate zsh completions
zsh -c "source ${DOTFILES}/zsh/functions/mkcompletions"

# Genearte gitconfig
zsh -c "gitconfig"
