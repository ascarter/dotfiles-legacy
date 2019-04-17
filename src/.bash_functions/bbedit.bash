#  -*- mode: unix-shell-script; -*-

# Open BBEdit
bb() {
	# If the bb command is called without an argument, launch BBEdit
	if [[ -z "$1" ]]; then
		bbedit --launch
	else
		# If bb is passed a file, open it in BBEdit
		bbedit "$1"
		if [[ -d "$1" ]]; then
			# If bb is passed a directory, cd to it
			cd "$1"
		fi
	fi
}

# Open URL source in BBEdit
bbcurl() {
	(curl "$@") | bbedit --new-window +1 -t curl
}

# Open manpage in BBEdit
bbman() {
	MANWIDTH=80 MANPAGER='col -bx' man ${@} | bbedit --clean --view-top --language Manpage -t "man ${@}"
}

# Run make and send results to bbresults
bbmake() {
	bbr make $*
}

# Run command and send results to bbresults
# filters any leading whitespace
bbr() {
	($* 2>&1) | sed -e 's/^[ \t]*//' | bbresults --errors-default
}

# Run command and send results to new BBEdit window
bbrun() {
	($* 2>&1) | bbedit --new-window +1 -t "$*"
}


# Set or turn off bbedit debug expert prefs
bbdebug() {
	local cmd=${1:-status}

	local keys=(
		DebugProjectListExpansion
		DebuggingLogSyntheticProject
		LogExceptions
		IncludeBacktraceWhenLoggingExceptions
	)

	case "$cmd" in
	on)
		for key in "${keys[@]}"; do
			defaults write com.barebones.bbedit ${key} -bool YES
		done
		;;
	off)
		for key in "${keys[@]}"; do
			defaults delete com.barebones.bbedit ${key}
		done
		;;
	ls|status)
		for key in "${keys[@]}"; do
			echo ${key} = $(defaults read com.barebones.bbedit ${key})
		done
		;;
	*)
		echo bbdebug [on|off|status]
		return
		;;
	esac
}
