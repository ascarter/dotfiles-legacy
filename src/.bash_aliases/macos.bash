#  -*- mode: unix-shell-script; -*-

case $(uname) in
Darwin )
	# ls
	alias ls='ls -hFGH'

	# macOS appearance
	alias darkmode='osascript -e "tell application \"System Events\" to tell appearance preferences to set dark mode to true"'
	alias lightmode='osascript -e "tell application \"System Events\" to tell appearance preferences to set dark mode to false"'
	alias switchmode='osascript -e "tell application \"System Events\" to tell appearance preferences to set dark mode to not dark mode"'

	# System shortcuts
	alias lockscreen='/System/Library/CoreServices/"Menu Extras"/User.menu/Contents/Resources/CGSession -suspend'
	alias ejectall='osascript -e "tell application \"Finder\" to eject (every disk whose ejectable is true)"'

	# System information
	alias about='system_profiler SPHardwareDataType SPSoftwareDataType SPStorageDataType'
	# Use sw_vers for version
	alias sysver='sw_vers'

	# Airport utility
	alias airport=/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport

	# Power managment
	alias keepawake='caffeinate -d -i -s'
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

	# YubiKey
	alias ykman='/Applications/YubiKey\ Manager.app/Contents/MacOS/ykman'

	# Dev tools
	alias gtower='gittower "$(P=$(pwd); while [[ "$P" != "" && ! -e "$P/.git" ]]; do P=${P%/*}; done; echo "$P")"'
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
