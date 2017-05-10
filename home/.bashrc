#  -*- mode: unix-shell-script; -*-

# ========================================
# Platform settings
# ========================================

case $(uname) in
Darwin )
	ulimit -n 5000
	# Add ssh keys added via ssh-add -K <key>
	ssh-add -A
esac

# ========================================
# Path settings
# ========================================

# Add home bin dir if it is there
if [ -d ~/.bin ]; then
	export PATH=~/.bin:${PATH}
fi

export PROJECTS_HOME=${PROJECTS_HOME:-${HOME}/Projects}

# ========================================
# Languages/frameworks
# ========================================

# Homebrew
if [ -n "`which brew`" ]; then
	BREW_PREFIX=`brew --prefix`
	export HOMEBREW_NO_EMOJI=1
	export HOMEBREW_NO_ANALYTICS=1
fi

# Go
if [ -n "`which go`" ]; then
	# Prefer ${PROJECTS_HOME}, fall back to ~/workspace
	if [ -d ${PROJECTS_HOME} ]; then
		export GOPATH=${PROJECTS_HOME}
	elif [ -d ~/workspace ]; then
		export GOPATH=~/workspace
	fi

	export PATH=$PATH:$(go env GOPATH)/bin
fi

# Ruby (rbenv)
if [ -d ~/.rbenv ]; then
	export PATH=~/.rbenv/bin:${PATH}
	eval "$(rbenv init -)"
fi

# NodeJS/Yarn
if [ -n "`which yarn`" ]; then
	export PATH=${PATH}:`yarn global bin`
fi

# Java
if [[ -e /usr/libexec/java_home ]]; then
	# Verify that java is installed
	/usr/libexec/java_home > /dev/null 2>&1
	if [[ $? -eq 0 ]]; then
		# Java installed - use the default JDK
		export JAVA_HOME=`/usr/libexec/java_home`
	fi
else
	export JAVA_HOME=$(readlink -f `which java` | sed "s:bin/java::")
fi

# Android
if [ -d ~/Library/Android/sdk ]; then
	export ANDROID_HOME=~/Library/Android/sdk
	export PATH=${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools
fi

# ========================================
# Applications/services
# ========================================

# GitHub
if [ -n "`which hub`" ]; then
	export GITHUB_USER=ascarter
	eval "$(hub alias -s)"
fi

# ========================================
# Shell functions
# ========================================

# Display current battery charge
batterycharge() { echo `python ~/.bin/batterycharge.py $*` 2>/dev/null ; }

# If the bb command is called without an argument, launch BBEdit
# If bb is passed a directory, cd to it and open it in BBEdit
# If bb is passed a file, open it in BBEdit
bb() {
	if [[ -z "$1" ]]; then
		bbedit --launch
	else
		bbedit "$1"
		if [[ -d "$1" ]]; then
			cd "$1"
		fi
	fi
}

# Open URL source in BBEdit
bbcurl() { (curl $*) | bbedit --new-window +1 -t curl; }

# Run command and send results to bbresults
# filters any leading whitespace
bbr() { ($* 2>&1) | sed -e 's/^[ \t]*//' | bbresults --errors-default ; }

# Run make and send results to bbresults
bbmake() { bbr make $* ; }

# Run command and send results to new BBEdit window
bbrun() { ($* 2>&1) | bbedit --new-window +1 -t "$*" ; }

# Switch to a project
scd() { cd ${PROJECTS_HOME}/src/${1} ; }

# Switch to github project
gcd() { cd ${PROJECTS_HOME}/src/github.com/${1} ; }

# Open query in dash
dashq() {
	if [ "${2}" ]; then
		open dash://${1}:${2}
	else
		open dash://${1}
	fi
}

# Fix open with list in Finder
fixow() {
	/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -domain local -domain user
	killall Finder
	echo "Open With has been rebuilt, Finder will relaunch"
}

# Open gem doc page
gemdoc() { open "http://localhost:8808/rdoc?q=$1" ; }

# Set JVM
set_jvm() {
	export JAVA_HOME=`/usr/libexec/java_home -v $1`
	java -version
}
java6() { set_jvm 1.6 ; }
java7() { set_jvm 1.7 ; }
java8() { set_jvm 1.8 ; }

# Mail file as attachment: <filepath> <subject> <recipient>
mailattach() { uuencode ${1} `basename $1` | mail -s "${2}" ${3} ; }

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

# Output colors: http://linuxtidbits.wordpress.com/2008/08/11/output-color-on-bash-scripts/
output_colors() {
	for i in $(seq 0 $(tput colors)); do
		echo " $(tput setaf $i)Text$(tput sgr0) $(tput bold)$(tput setaf $i)Text$(tput sgr0) $(tput sgr 0 1)$(tput setaf $i)Text$(tput sgr0)  \$(tput setaf $i)"
	done
}

# Switch to project home
project() { cd ~/Developer/Projects/${1} ; }

# Set tab name
tabname() { printf "\e]1;${1}\a" ; }

# Set window title
winname() { printf "\e]2;${1}\a" ; }

# Search up path until target directory is found
upsearch() {
	local P=$(pwd)
	while [[ "$P" != "" && ! -e "$P/$1" ]]; do
		P=${P%/*}
	done
	echo "$P"
}

# Source bash functions
for f in ~/.bash_functions/*; do
	. ${f}
done

# Source git-prompt
case $(uname) in
Darwin )
	if [ -d /Library/Developer/CommandLineTools ]; then
		. /Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh
	fi
	;;
esac

# ========================================
# Shell preferences
# ========================================

# Editor
if [ -e /usr/local/bin/bbedit ]; then
	# bbedit
	export EDITOR="bbedit -w"
	export VISUAL="bbedit"
	export LESSEDIT='bbedit -l %lm %f'
	export TEXEDIT='bbedit -w -l %d "%s"'
else
	# vim
	export EDITOR="mvim --nofork"
	export VISUAL="mvim"
	export LESSEDIT='vim ?lm+%lm. %f'
	export TEXEDIT='vim +%d %s'
fi

# Other editors
# if [ -e /usr/local/bin/atom ]; then
# 	# Atom
# 	export EDITOR="atom --wait"
# 	export VISUAL="atom"
# fi

# less
export PAGER=less
export LESS="--status-column --long-prompt --no-init --quit-if-one-screen --quit-at-eof -R"

# Command history
# bind '"[A":history-search-backward'
# bind '"[B":history-search-forward'

# ========================================
# Terminal settings
# ========================================

# Colors
case "${TERM}" in
xterm-256color|xterm-color|xterm|dtterm|linux)
	case $(uname) in
	Darwin )
		termtheme spartan
		;;
	esac
	;;
esac

# Docker
# PS1='[\u@\h \W$(__docker_machine_ps1 " [%s]")]\$ '

# Set Git PS conditions
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"

# Prompt
_git_prompt_command() {
	if [[ ${BASH_VERSINFO[0]} -lt 4 ]]; then
		PROMPT_DIR="\W"
	else
		PROMPT_DIR="\w"
	fi

	case "${TERM}" in
	xterm-256color|xterm-color|dtterm|linux)
		export GIT_PS1_SHOWCOLORHINTS=1
		__git_ps1 "$(tput bold)\n\u@\h$(tput sgr0):${PROMPT_DIR}" "\n\\\$ "
		;;
	*)
		__git_ps1 "\n\u@\h$:${PROMPT_DIR}" "\n\\\$ "
		;;
	esac
}

PS1='\n\u@\h:\W\n\$ '
if [[ $(type -t '__git_ps1') == function ]]; then
	PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }_git_prompt_command"
fi

# Limit paths to 3 levels (Bash version 4+)
export PROMPT_DIRTRIM=3

if which dircolors &>/dev/null; then
	if [ -e ~/.dircolors ]; then
			eval `dircolors ~/.dir_colors`
	fi
fi

# ========================================
# Aliases
# ========================================

case $(uname) in
Darwin )
	# ls
	alias ls='ls -hFGH'

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
Linux )
	alias ls='ls -hFH --color=auto'

	alias glock='gnome-screensaver-command --lock'
	alias xlock='xscreensaver-command -lock'
	;;
esac

alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lsd="ls -l | grep --color=never '^d'"
alias lsz="ls -lAh | grep -m 1 total | sed 's/total //'"

alias rs='resize -s 40 120'
alias rst='resize -s 0 120'

# refresh shell
alias reload='source ~/.profile'

# up 'n' folders
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias filetree="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/ /' -e 's/-/|/'"

# Search/grep
alias devgrep="grep -n -r --exclude='.svn' --exclude='*.swp' --exclude='.git'"

# IP addresses
# ip list
alias ip='ifconfig | grep "inet " | grep -v 127.0.0.1 | cut -d " " -f2'
# verbose ip list
alias ipv="ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1'"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"
# local ip
alias localip="ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'"
# external ip
alias wanip="dig +short myip.opendns.com @resolver1.opendns.com"

# local ip - expects en0 | en1 | ...
# alias localip="ipconfig getifaddr"

# View HTTP traffic
alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"
alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

# SSH
alias sshagentstart='eval "$(ssh-agent -s)" && ssh-add -A'

# AWS
alias awst='aws --output table'

# Docker
# Remove stopped containers
alias dockerrms='docker rm $(docker ps -a -q)'
# Remove all untagged images
alias dockerrmi='docker rmi $(docker images | grep "^<none>" | awk "{print $3}")'
# Connect shell to default machine
alias dockerdefault='eval "$(docker-machine env default)"'

# Go
alias gopresent='present -play=true &; open -g http://127.0.0.1:3999; fg'
alias gogetd='go get -d'
alias godocw='godoc -http=:6060 -play -q'

# Ruby
alias binit="bundle install --path vendor/bundle"
alias bstubs="bundle install --binstubs"
alias bexec="bundle exec"
alias bignore="echo \".bundle\nvendor/bundle/ruby\n\" >> .gitignore"
alias gman="gem man -s"
alias r="bin/rails"

# Python
alias rmpyc='find . -type f -name \*.pyc -print | xargs rm'
alias pydocv='python -m pydoc'
alias editvenv='bbedit --new-window ${VIRTUAL_ENV}'
alias pipbrew='CFLAGS="-I/opt/homebrew/include -L/opt/homebrew/lib" pip'
alias pdb='python -m pdb'
alias pyunittest='python -m unittest discover --buffer'

# Node.js
alias npmlist='npm list --depth=0'

# Subverison
alias svnfmdiff='svn diff --diff-cmd /usr/local/bin/fmdiff'
alias svnfmmerge='svn merge --diff3-cmd /usr/local/bin/fmdiff3'
alias svnfmup='svn update --diff3-cmd /usr/local/bin/fmdiff3'
alias svnbbdiff='svn diff --diff-cmd bbdiff --extensions "--resume --wait --reverse"'
alias svnbbmerge='svn merge --diff3-cmd bbdiff'
alias svnbbup='svn update --diff3-cmd bbdiff'

# Shortcuts
alias projects='cd ${PROJECTS_HOME}'
alias src='cd ${PROJECTS_HOME}/src'
alias mysrc='cd ${PROJECTS_HOME}/src/github.com/ascarter'

# Ski
alias whistlertom='curl -o ~/Documents/whistler_tom.pdf -L "http://online.whistlerblackcomb.com/TomPDF/Default.aspx?Season=1&Type=bg" && ql ~/Documents/whistler_tom.pdf'

# Stopwatch
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'

# Intuitive map function
# For example, to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname
alias map="xargs -n1"

# Canonical hex dump; some systems have this symlinked
command -v hd > /dev/null || alias hd="hexdump -C"

# ========================================
# Bash completions
# ========================================

# Source any user bash completion scripts
if [ -d ~/.bash_completion.d ]; then
	for f in ~/.bash_completion.d/*; do
		source ${f}
	done
fi

# Source git completions
case $(uname) in
Darwin )
	if [ -d /Library/Developer/CommandLineTools ]; then
		. /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash
	fi
	;;
esac

# Source docker completion
if [ -d /Applications/Docker.app ]; then
	for f in /Applications/Docker.app/Contents/Resources/etc/*.bash-completion; do
		source ${f}
	done
fi

# Homebrew - will also call user's ~/.bash_completion too
if [ -n "`which brew`" ]; then
	if [ -f `brew --prefix`/etc/bash_completion ]; then
		. `brew --prefix`/etc/bash_completion
	fi

	if [ -e `brew --prefix`/bin/aws_completer ]; then
		complete -C aws_completer aws
	fi
fi

# Pip
if [ -n "`which pip`" ]; then
	eval "`pip completion --bash`"
fi

# ========================================
# Per-machine extras
# ========================================
if [ -e ~/.bash_local ]; then
	. ~/.bash_local
fi