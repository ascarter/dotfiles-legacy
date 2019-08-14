#  -*- mode: unix-shell-script; -*-

fpath=(${ZDOTDIR:-$DOTFILES/zsh}/completions ${ZDOTDIR:-$DOTFILES/zsh}/functions ${ZDOTDIR:-$DOTFILES/zsh}/prompts $fpath)

# Homebrew
HOMEBREW_PREFIX=/opt/homebrew
if type ${HOMEBREW_PREFIX}/bin/brew &>/dev/null; then
	export HOMEBREW_NO_EMOJI=1
	export HOMEBREW_NO_ANALYTICS=1
	eval $(${HOMEBREW_PREFIX}/bin/brew shellenv)
	fpath+=($(brew --prefix)/share/zsh/site-functions $(brew --prefix)/share/zsh-completions)
fi

autoload -U compinit
compinit -u

autoload -U promptinit
promptinit

autoload -U colors
colors

autoload -U ${ZDOTDIR:-$DOTFILES/zsh}/functions/[^_]*(:t)
autoload add-zsh-hook

# Support bash completions
autoload bashcompinit
bashcompinit

# Enable vcs info
autoload -Uz vcs_info

# ========================================
# SSH Agent
# ========================================

# Enable GPG for SSH
# if [ -S $(gpgconf --list-dirs agent-ssh-socket) ]; then
# 	export GPG_TTY=$(tty)
# 	export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
# fi

# ===========
# Prompt
# ===========

# Default: PS1="%m%# "
declare +x PS1
prompt vcs

if [[ ${TERM_PROGRAM} = "Apple_Terminal"  &&  -z ${INSIDE_EMACS} ]]; then
    add-zsh-hook chpwd update_terminal_cwd
    update_terminal_cwd
fi

# ========================================
# Shell preferences
# ========================================

# Retain history across multiple zsh sessions
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
SAVEHIST=5000
HISTSIZE=2000

# Enable corrections
setopt CORRECT
setopt CORRECT_ALL

# Key mappings

# Forward delete
bindkey "^[[3~" delete-char

# Editor
if [ -e /usr/local/bin/bbedit ]; then
	# bbedit
	export EDITOR="bbedit --wait --resume"
	export VISUAL="bbedit"
	export LESSEDIT='bbedit -l %lm %f'
	export TEXEDIT='bbedit -w -l %d "%s"'
else
	# vim
	export EDITOR="vim"
	export VISUAL=${EDITOR}
	export LESSEDIT='vim ?lm+%lm. %f'
	export TEXEDIT='vim +%d %s'
fi

# less
export PAGER=less
export LESS="--status-column --long-prompt --no-init --quit-if-one-screen --quit-at-eof -R"

# Colors
case "${TERM}" in
xterm-256color|xterm-color|xterm|dtterm|linux)
	case $(uname) in
	Darwin )
		terminal_theme spartan
		;;
	Linux )
		if type dircolors &>/dev/null && [ -e ${HOME}/.dircolors ]; then
			eval $(dircolors ${HOME}/.dir_colors)
		fi
		;;
	esac
	;;
esac

# ========================================
# Frameworks/Languages
# ========================================

# Go
if type go &>/dev/null; then
	export PATH=$(go env GOPATH)/bin:${PATH}
fi

# Ruby
if type ruby &>/dev/null && type gem &>/dev/null; then
	export PATH=$(ruby -r rubygems -e 'puts Gem.user_dir')/bin:$PATH
fi

# Python
if [[ -d /Library/Frameworks/Python.framework/Versions/3.7 ]]; then
	export PATH=/Library/Frameworks/Python.framework/Versions/3.7/bin:${PATH}
fi
if [[ -d ${HOME}/Library/Python/3.7 ]]; then
	export LC_ALL=en_US.UTF-8
	export LANG=en_US.UTF-8
	export PATH=${HOME}/Library/Python/3.7/bin:${PATH}
fi
if type pip3 &>/dev/null; then
	source <(pip3 completion --zsh)
	compctl -K _pip_completion pip3
fi
if [[ -d ${HOME}/Library/Python/2.7 ]]; then
	export PATH=${HOME}/Library/Python/2.7/bin:${PATH}
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
	export JAVA_HOME=$(readlink -f `whence -cp java` | sed "s:bin/java::")
fi

# Android
if [[ -d ${HOME}/Library/Android/sdk ]]; then
	export ANDROID_HOME=${HOME}/Library/Android/sdk
	export PATH=${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${PATH}
fi

# Rust
if [[ -d ${HOME}/.cargo ]]; then
	export PATH=${HOME}/.cargo/bin:$PATH
fi

# GitHub
if type hub &>/dev/null; then
	export GITHUB_USER=ascarter
	eval $(`whence -cp hub` alias -s)
fi

# Kubernetes
if type kubectl &>/dev/null; then
	source <(kubectl completion zsh)
fi

# AWS
if type aws_zsh_completer.sh &>/dev/null; then
	source `whence -cp aws_zsh_completer.sh`
fi

# ========================================
# Aliases
# ========================================

# zsh
alias resetcomp='rm -f ${HOME}/.zcompdump && compinit'

# dotfiles home folder
alias dotf='cd ${DOTFILES}/'

# Projects
alias projects='cd ${HOME}/Projects'

# ls
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lsd="ls -l | grep --color=never '^d'"
alias lsz="ls -lAh | grep -m 1 total | sed 's/total //'"
alias filetree="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/ /' -e 's/-/|/'"

# Search/grep
alias devgrep="grep -n -r --exclude='.svn' --exclude='*.swp' --exclude='.git'"

# Stopwatch
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'

# Intuitive map function
# For example, to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname
alias map="xargs -n1"

# Canonical hex dump; some systems have this symlinked
command -v hd > /dev/null || alias hd="hexdump -C"

# Resize terminal
alias rs='resize -s 40 120'
alias rst='resize -s 0 120'

# Ski
alias whistlertom='curl -o ${HOME}/Documents/whistler_tom.pdf -L "http://online.whistlerblackcomb.com/TomPDF/Default.aspx?Season=1&Type=bg" && ql ${HOME}/Documents/whistler_tom.pdf'

# BBEdit aliases
alias bbctags='/Applications/BBEdit.app/Contents/Helpers/ctags'
alias bbd=bbdiff
alias bbmake="bbr make"
alias bbnw='bbedit --new-window'
alias bbpb='pbpaste | bbedit --clean --view-top'
alias bbtags='bbedit --maketags'

# Docker aliases
alias dcm=docker-compose

# Remove stopped containers
alias dockerrms='docker rm $(docker ps -a -q)'

# List untagged images
alias dockeruntagged='docker images --filter "dangling=true"'

# Run docker sandbox
alias druby="docker_ruby ruby"
alias dgem="docker_ruby gem"
alias dbundle="docker_ruby bundle"
alias dnode="docker_node node"
alias dnpm="docker_node npm"
alias dgo="docker_go go"
alias dgomake="docker_go make"
alias dpy="docker_python python"
alias dpip="docker_python pip"

# Ruby
alias binit="bundle install --path vendor/bundle"
alias bstubs="bundle install --binstubs"
alias bexec="bundle exec"
alias bignore="echo \".bundle\nvendor/bundle/ruby\n\" >> .gitignore"
alias gman="gem man -s"
alias r="bin/rails"
alias gemu="ruby -r rubygems -e 'puts Gem.user_dir'"
alias gemuinstall="gem install --user-install"

# Go
alias gopresent='present -play=true &; open -g http://127.0.0.1:3999; fg'
alias godocw='godoc -http=:6060 -play -q'

# Java
alias java6="set_jvm 1.6"
alias java7="set_jvm 1.7"
alias java8="set_jvm 1.8"
alias java9="set_jvm 9"
alias java10="set_jvm 10"
alias java11="set_jvm 11"
alias java12="set_jvm 12"

# Node.js
alias npmlist='npm list --depth=0'

# Python
alias rmpyc='find . -type f -name \*.pyc -print | xargs rm'
alias pydocv='python -m pydoc'
alias editvenv='bbedit --new-window ${VIRTUAL_ENV}'
alias pipbrew='CFLAGS="-I/opt/homebrew/include -L/opt/homebrew/lib" pip'
alias pdb='python -m pdb'
alias pyunittest='python -m unittest discover --buffer'

# GPG/PGP aliases
alias kpgp='keybase pgp'

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
alias sshagentstart='eval $(ssh-agent -s) && ssh-add -A'

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

	# YubiKey
	alias ykman='/Applications/YubiKey\ Manager.app/Contents/MacOS/ykman'

	# Dev tools
	alias extags='/opt/homebrew/bin/ctags'
	alias verifyxcode='spctl --assess --verbose /Applications/Xcode.app'
	alias sketchtool="$(mdfind kMDItemCFBundleIdentifier = 'com.bohemiancoding.sketch3' | head -n 1)/Contents/Resources/sketchtool/bin/sketchtool"

	# Java
	alias java_home='/usr/libexec/java_home'

	# Use MacVim on Mac OS X if installed
	[[ -e /usr/local/bin/vim ]] && alias vim='/usr/local/bin/vim'
	;;
Linux )
	alias ls='ls -hFH --color=auto'

	alias glock='gnome-screensaver-command --lock'
	alias xlock='xscreensaver-command -lock'
	;;
esac

# ========================================
# Path settings
# ========================================

# Add home bin dir if it is there
if [[ -d ${DOTFILES}/bin ]]; then
	export PATH=${DOTFILES}/bin:${PATH}
fi

# ========================================
# Per-machine extras
# ========================================
if [[ -e ${HOME}/.zsh_local ]]; then
	source ${HOME}/.zsh_local
fi
