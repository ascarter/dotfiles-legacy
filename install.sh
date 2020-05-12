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
