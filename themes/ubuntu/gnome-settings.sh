#!/bin/sh

# Set GNOME preferences

# Dash-to-dock
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash true

# Dash-to-panel
gsettings set org.gnome.shell.extensions.dash-to-panel intellihide true
