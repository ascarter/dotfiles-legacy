#!/bin/sh

#
# Install script for dotfiles
# Run this script on a new install of macOS

if [[ -z `which xcode-select` ]]; then
	echo "Install Xcode from macOS app store."
	open https://itunes.apple.com/us/app/xcode/id497799835?mt=12
	exit 1
fi

# Check for Xcode command line tools
if [[ ! -d /Library/Developer/CommandLineTools ]]; then
	xcode-select --install
fi

# Check if dotfiles installed
if [[ ! -d ~/.dotfiles ]]; then
	git clone git@github.com:ascarter/dotfiles ~/.dotfiles
fi

# Run initial bootstrap
cd ~/.dotfiles
#rake
