#  -*- mode: unix-shell-script; -*-

case $(uname) in
Linux )
	alias ls='ls -hFH --color=auto'

	alias glock='gnome-screensaver-command --lock'
	alias xlock='xscreensaver-command -lock'
	;;
esac
