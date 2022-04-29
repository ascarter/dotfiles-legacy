#!/bin/sh

# Install pop theme on Ubuntu

sudo apt-get update
sudo apt-get install -y \
              pop-gnome-shell-theme \
              pop-gtk-theme \
              pop-icon-theme \
              pop-sound-theme

# Create wallpaper
pop_os_wallpaper=~/Pictures/Wallpapers/pop-os/wallpapers
if ! [ -d ${pop_os_wallpaper} ]; then
  mkdir -p $(dirname ${pop_os_wallpaper})
  git clone https://github.com/pop-os/wallpapers.git ${pop_os_wallpaper}
fi
make -C ~/Pictures/Wallpapers/pop-os/wallpapers -j
sudo make -C ~/Pictures/Wallpapers/pop-os/wallpapers install

# TODO: Set gnome configuration
echo "Recommendations for Gnome configuration:"
echo ""
echo "Icons: Pop Icon Theme"
echo "Theme: Pop GTK Theme"
echo ""
echo "For fonts, use:"
echo "Window Titles: Fira Sans SemiBold 10"
echo "Interface:     Fira Sans Book 10"
echo "Documents:     Roboto Slab Regular 11"
echo "Monospace:     Fira Mono Regular 11"
