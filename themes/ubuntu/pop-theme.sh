#!/bin/sh

# Install pop theme on Ubuntu

sudo apt-get update
sudo apt-get install -y \
              pop-gnome-shell-theme \
              pop-gtk-theme \
              pop-icon-theme \
              pop-sound-theme

# Checkout and build fonts
#local fontdir=$(mkdtemp -d)
#git clone https://github.com/pop-os/fonts.git ${fontdir}/fonts
#pushd ${fontdir}/fonts
#make install
