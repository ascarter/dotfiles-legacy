#!/bin/sh

DOTFILES_ROOT="$(cd "$(dirname "$0")"; pwd -P)"

# Remove home directory symlinks
for source in ${DOTFILES_ROOT}/home/*; do
	filename=$(basename ${source})
	target=${HOME}/.${filename}
	if [ -e ${target} ]; then
		printf "Remove ${target}\n"
		rm ${target}
	fi
done

# Uninstall homebrew

