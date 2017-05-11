#  -*- mode: unix-shell-script; -*-

# Open man page with default x-man handler
# On Mac OS X, opens a nice terminal window
manx() {
	if [ "${2}" ]; then
		open x-man-page://${1}/${2}
	else
		open x-man-page://${1}
	fi
}

# Open man page as PDF
# On Mac OS X, uses Preview.app
pman() { man -t ${@} | open -f -a /Applications/Preview.app ; }

