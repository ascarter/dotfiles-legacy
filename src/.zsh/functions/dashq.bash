#  -*- mode: unix-shell-script; -*-

# Open query in dash
dashq() {
	if [ "${2}" ]; then
		open dash://${1}:${2}
	else
		open dash://${1}
	fi
}
