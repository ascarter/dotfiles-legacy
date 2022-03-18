#!/bin/sh
#
# Uninstall script for dotfiles configuration
#
# Usage:
#	uninstall [home] [dotfiles]
#
#	home   == home directory (default ${HOME})
# 	target == destination for enlistment (default ~/.config/dotfiles)
#

set -ue

HOMEDIR="${1:-${HOME}}"
DOTFILES="${2:-${HOME}/.config/dotfiles}"

# Remove home directory symlinks
for f in $(ls ${DOTFILES}/conf); do
  target=${HOMEDIR}/.${f}
  if [ -e ${target} ]; then
    echo "Remove ${target}"
    rm ${target}
  fi
done

echo "dotfiles uninstalled"
