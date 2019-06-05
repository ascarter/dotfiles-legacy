#  -*- mode: unix-shell-script; -*-

# Source git-prompt
case $(uname) in
Darwin )
	if [ -d /Library/Developer/CommandLineTools ]; then
		. /Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh
	fi
	;;
esac
