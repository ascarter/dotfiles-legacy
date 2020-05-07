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

# Clone dotfiles
if ! [ -e ${DOTFILES} ]; then
	mkdir -p $(dirname ${DOTFILES})
	git clone https://github.com/ascarter/dotfiles ${DOTFILES}
fi

# Symlink rc files
mkdir -p ${HOMEDIR}
for f in $(ls ${DOTFILES}/conf); do
	t=${HOMEDIR}/.$(basename ${f})
	if ! [ -e ${t} ]; then
		echo "Symlink ${f} -> ${t}"
		ln -s ${f} ${t}
	fi
done

# Configure zsh if installed
if command -v zsh &>/dev/null; then
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

echo "dotfiles installed."
