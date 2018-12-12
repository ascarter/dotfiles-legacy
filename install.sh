#!/bin/sh

#
# Install script for dotfiles
# Run this script on a new install of macOS
#

function pause() {
	read -rsp $'Press any key to continue...\n' -n1 key
}

if [[ -z `which xcode-select` ]]; then
	echo "Install Xcode from macOS app store."
	open https://itunes.apple.com/us/app/xcode/id497799835?mt=12
	exit 1
fi

# Check for Xcode command line tools
if [[ ! -d /Library/Developer/CommandLineTools ]]; then
	xcode-select --install
fi

# Check if ssh key present
if [[ ! -f ~/.ssh/id_rsa ]]; then
	echo "Generating SSH key"
	read -p "Email: ", email
	ssh-keygen -t rsa -b 4096 -C "${email}"
	pbcopy < ~/.ssh/id_rsa.pub
	open https://github.com/settings/ssh/new
	pause
fi

# Check if dotfiles installed
if [[ ! -d ~/.dotfiles ]]; then
	git clone git@github.com:ascarter/dotfiles ~/.dotfiles
fi

# Run initial bootstrap
cd ~/.dotfiles
#rake
