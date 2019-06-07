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
# SSH Agent
# ========================================

# Enable GPG for SSH
# if [ -S $(gpgconf --list-dirs agent-ssh-socket) ]; then
# 	export GPG_TTY=$(tty)
# 	export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
# fi

# ========================================
# Languages/frameworks
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

if [ -d ~/Library/Python/2.7 ]; then
	export PATH=~/Library/Python/2.7/bin:${PATH}
fi

if [ -d ~/Library/Python/3.7 ]; then
	export PATH=~/Library/Python/3.7/bin:${PATH}
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

# Perl
if [ -d ~/perl5 ]; then
	export PATH=~/bin${PATH:+:${PATH}}
	export PERL5LIB=~/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}
	export PERL_LOCAL_LIB_ROOT=~/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}
	export PERL_MB_OPT="--install_base ~/perl5"
	export PERL_MM_OPT="INSTALL_BASE=~/perl5"
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
	for f in docker docker-compose docker-machine; do
		source /Applications/Docker.app/Contents/Resources/etc/${f}.bash-completion
	done
fi

# Source kubernetes completion
if [ -n "`which kubectl`" ]; then
	eval "`kubectl completion bash`"
fi

# Source Swift completion
if [ -n "`which swift`" ]; then
	eval "`swift package completion-tool generate-bash-script`"
fi

# Source Rust completion
if [ -n "`which rustup`" ]; then
	eval "`rustup completions bash`"
fi

# Source AWS CLI completion
if [ -f ${HOMEBREW_PREFIX}/Caskroom/awscli-bundled/lib/bin/aws_completer ]; then
	complete -C ${HOMEBREW_PREFIX}/Caskroom/awscli-bundled/lib/bin/aws_completer aws
fi

# Homebrew - will also call user's ~/.bash_completion too
if [ -n "`which brew`" ]; then
	if [ -f ${HOMEBREW_PREFIX}/etc/bash_completion ]; then
		. ${HOMEBREW_PREFIX}/etc/bash_completion
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

# ykman completions
if [ -f /Applications/YubiKey\ Manager.app/Contents/MacOS/ykman ]; then
	source <(_YKMAN_COMPLETE=source /Applications/YubiKey\ Manager.app/Contents/MacOS/ykman)
fi

# ========================================
# Per-machine extras
# ========================================
if [ -e ~/.bash_local ]; then
	. ~/.bash_local
fi
