#  -*- mode: unix-shell-script; -*-

# Symlink home directory files
for f in home/*; do
	local FILENAME=$(basename ${f})
	local SOURCE=$(pwd)/${f}
	local TARGET=${HOME}/.${FILENAME}
	ln -s ${SOURCE} ${TARGET}
done

# Install homebrew

# Git config