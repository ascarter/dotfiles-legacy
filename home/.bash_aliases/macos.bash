#  -*- mode: unix-shell-script; -*-

case $(uname) in
Darwin )
	# ls
	alias ls='ls -hFGH'

	# SSH init
	# Initialize ssh agent and add keys
	alias sshi='eval "$(ssh-agent -s)" && ssh-add -A'

	# System shortcuts
	alias lockscreen='/System/Library/CoreServices/"Menu Extras"/User.menu/Contents/Resources/CGSession -suspend'

	# System information
	alias about='system_profiler SPHardwareDataType SPStorageDataType'
	alias aboutsys='system_profiler SPSoftwareDataType'
	# Use sw_vers for version
	alias sysver='sw_vers'

	# Airport utility
	alias airport=/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport

	# Power managment
	alias sleepnow='pmset sleepnow'
	alias batterycapacity='ioreg -w0 -c AppleSmartBattery -b -f | grep -i capacity'

	# QuickLook
	alias ql='qlmanage -p "$@" >& /dev/null'

	# BBEdit
	alias bbctags='/Applications/BBEdit.app/Contents/Helpers/ctags'
	alias bbd=bbdiff
	alias bbnw='bbedit --new-window'
	alias bbpb='pbpaste | bbedit --clean --view-top'
	alias bbtags='bbedit --maketags'

	# Dev tools
	alias gtower='gittower $(P=$(pwd); while [[ "$P" != "" && ! -e "$P/.git" ]]; do P=${P%/*}; done; echo "$P")'
	alias extags='/opt/homebrew/bin/ctags'
	alias eclipse='open /Developer/Applications/Eclipse.app'
	alias vmrun='/Applications/VMware\ Fusion.app/Contents/Library/vmrun'
	alias terminal-notifier='/Applications/terminal-notifier.app/Contents/MacOS/terminal-notifier'
	alias verifyxcode='spctl --assess --verbose /Applications/Xcode.app'

	# Java
	alias java_home='/usr/libexec/java_home'

	# Use MacVim on Mac OS X if installed
	if [ -e /usr/local/bin/vim ]; then
			alias vim='/usr/local/bin/vim'
	fi
	;;
esac
