#  -*- mode: unix-shell-script; -*-

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
		if [ -d ${PROJECTS_HOME}/workspace ]; then
			export GOPATH=${PROJECTS_HOME}/workspace
		else
			export GOPATH=${PROJECTS_HOME}
		fi
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

# Python
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

# ========================================
# Applications/services
# ========================================

# GitHub
if [ -n "`which hub`" ]; then
	export GITHUB_USER=ascarter
	eval "$(hub alias -s)"
fi

# MacVim
if [ -d /Applications/MacVim.app ]; then
	export PATH=/Applications/MacVim.app/Contents/bin:${PATH}
fi

# ========================================
# Shell functions
# ========================================

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

# Source bash aliases
for f in ~/.bash_aliases/*; do
	. ${f}
done

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
	for f in docker docker-compose; do
		source /Applications/Docker.app/Contents/Resources/etc/${f}.bash-completion
	done
fi

# Source Swift completion
if [ -n "`which swift`" ]; then
	eval "`swift package completion-tool generate-bash-script`"
fi

# Source AWS CLI completion
if [ -f /usr/local/aws/bin/aws_bash_completer ]; then
	source /usr/local/aws/bin/aws_bash_completer
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

# NodeJS
if [ -n "`which npm`" ]; then
	source <(npm completion)
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
