#  -*- mode: unix-shell-script; -*-

# Fix open with list in Finder
fixow() {
	/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -domain local -domain user
	killall Finder
	echo "Open With has been rebuilt, Finder will relaunch"
}
