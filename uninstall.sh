#!/bin/sh
#
# Uninstall script for dotfiles configuration
#
# Usage:
#	uninstall [home] [dotfiles]
#
#	home   == home directory (default ${HOME})
# target == destination for enlistment (default ~/.config/dotfiles)
#

set -ue

HOMEDIR="${1:-${HOME}}"
DOTFILES="${2:-${DOTFILES:-${HOMEDIR}/.config/dotfiles}}"

# Remove home directory symlinks
conf_dir=${DOTFILES}/conf
for f in $(find ${conf_dir} -type f -print); do
  t=${HOMEDIR}/.${f#${conf_dir}/}
  if [ -h ${t} ]; then
    # Remove symlink
    echo "Remove ${t}"
    rm ${t}

    # Restore backup if present
    if [ -e ${t}.orig ]; then
      echo "Restore ${t}.orig -> ${t}"
      mv ${t}.orig ${t}
    fi
  fi
done

echo "dotfiles uninstalled"
