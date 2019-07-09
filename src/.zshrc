#  -*- mode: unix-shell-script; -*-

fpath=(${ZDOTDIR:-$HOME/.zsh}/functions ${ZDOTDIR:-$HOME/.zsh}/prompts /opt/homebrew/share/zsh/site-functions /opt/homebrew/share/zsh-completions $fpath)

autoload -U compinit
compinit -u

autoload -U promptinit
promptinit

autoload -U colors
colors

autoload -U ${ZDOTDIR:-$HOME/.zsh}/functions/[^_]*(:t)
autoload add-zsh-hook

# Load git prompt
case $(uname) in
Darwin )
	if [ -d /Library/Developer/CommandLineTools ]; then
		source /Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh
	fi
	;;
esac


# ===========
# Prompt
# ===========

# Default
# PS1="%m%# "
declare +x PS1

# Set Git PS conditions
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"
case "${TERM}" in
xterm-256color|xterm-color|dtterm|linux)
	export GIT_PS1_SHOWCOLORHINTS=1
	;;
esac

prompt ascarter


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
		if which dircolors &>/dev/null; then
			if [ -e ~/.dircolors ]; then
					eval `dircolors ~/.dir_colors`
			fi
		fi
		;;
	esac
	;;
esac

# ========================================
# Frameworks/Languages
# ========================================

# Homebrew
if [ -n "`which brew`" ]; then
	export HOMEBREW_NO_EMOJI=1
	export HOMEBREW_NO_ANALYTICS=1
	eval $(brew shellenv)
fi

# Go
if [ -n "`which go`" ]; then
	export PATH=$PATH:$(go env GOPATH)/bin
fi

# Ruby
if [ -n "`which ruby`" ] && [ -n "`which gem`" ]; then
	export PATH=$(ruby -r rubygems -e 'puts Gem.user_dir')/bin:$PATH
fi

# Python
if [ -d /Library/Frameworks/Python.framework/Versions/3.7 ]; then
	export PATH=/Library/Frameworks/Python.framework/Versions/3.7/bin:${PATH}
fi

if [ -d ~/Library/Python/3.7 ]; then
	export LC_ALL=en_US.UTF-8
	export LANG=en_US.UTF-8
	export PATH=~/Library/Python/3.7/bin:${PATH}
fi

if [ -d ~/Library/Python/2.7 ]; then
	export PATH=~/Library/Python/2.7/bin:${PATH}
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

# Rust
if [ -d ~/.cargo ]; then
	export PATH="$HOME/.cargo/bin:$PATH"
fi

# GitHub
if [ -n "`which hub`" ]; then
	export GITHUB_USER=ascarter
	eval "$(hub alias -s)"
fi

# ========================================
# Aliases
# ========================================

# Resize terminal
alias rs='resize -s 40 120'
alias rst='resize -s 0 120'

# BBEdit aliases
alias bbmake="bbr make"

# Docker aliases
alias druby="docker_ruby ruby"
alias dgem="docker_ruby gem"
alias dbundle="docker_ruby bundle"
alias dnode="docker_node node"
alias dnpm="docker_node npm"
alias dgo="docker_go go"
alias dgomake="docker_go make"
alias dpy="docker_python python"
alias dpip="docker_python pip"

# Java aliases
alias java6="set_jvm 1.6"
alias java7="set_jvm 1.7"
alias java8="set_jvm 1.8"
alias java9="set_jvm 9"
alias java10="set_jvm 10"
alias java11="set_jvm 11"
alias java12="set_jvm 12"

# Shortcuts
alias projects='cd ${PROJECTS_HOME}'
