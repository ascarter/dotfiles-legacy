#!/bin/sh
#
# Uninstall script for dotfiles configuration
#
# Usage:
#	uninstall [target] [homedir]
#
# 	target   == destination for enlistment (default ~/.config/dotfiles)
#	homedir  == home directory (default ${HOME})
#

set -ue

DOTFILES="${1:-${HOME}/.config/dotfiles}"
HOMEDIR="${2:-${HOME}}"
RC_FILES=""

case "$(uname)" in
Darwin ) RC_FILES=${RC_FILES}" Brewfile" ;;
esac

# Remove home directory symlinks
RC_FILES="$(cat ${DOTFILES}/rc.conf) "${RC_FILES}
for f in ${RC_FILES}; do
	target=${HOMEDIR}/.${f}
	if [ -e ${target} ]; then
		echo "Remove ${target}"
		rm ${target}
	fi
done
