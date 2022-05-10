#!/bin/sh

case "$(uname)" in
Linux )
  case $(lsb_release -i -s) in
  Ubuntu )
    if [ "$(lsb_release -cs)" = "focal" ]; then

      # Install pop theme and shell on Ubuntu 20.04 via PPA
      # sudo add-apt-repository ppa:system76/pop
      # sudo apt-get update
      # sudo apt-get install -y
      #               pop-launcher \
      #               pop-shell \
      #               pop-shell-shortcuts \
      #               pop-theme

      # Install pop theme
      sudo apt-get install -y \
                pop-gnome-shell-theme \
                pop-gtk-theme \
                pop-icon-theme \
                pop-sound-theme

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
    fi
    ;;
  esac
esac
