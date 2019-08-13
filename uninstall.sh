#!/bin/sh

set -ueo pipefail

#
# Uninstall script for dotfiles configuration
#
# Usage:
#	uninstall [dotfiles]
#
# Defaults:
#	dotfiles = ~/.config/dotfiles
#

DOTFILES=${1:-${HOME}/.config/dotfiles}

# Remove home directory symlinks
for f in $(cat ${DOTFILES}/rc.conf); do
	target=${HOME}/.${f}
	if [ -e ${target} ]; then
		echo "Remove ${target}"
		rm ${target}
	fi
done

