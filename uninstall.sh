#  -*- mode: unix-shell-script; -*-

# Remove home directory symlinks
for f in home/*; do
	local FILENAME=$(basename ${f})
	local TARGET=${HOME}/.${FILENAME}
	rm ${TARGET}
done

# Uninstall homebrew

# Git config