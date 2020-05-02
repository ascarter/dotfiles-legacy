#  -*- mode: shellscript; -*-

fpath=(${ZDOTDIR:-$DOTFILES/zsh}/completions ${ZDOTDIR:-$DOTFILES/zsh}/functions ${ZDOTDIR:-$DOTFILES/zsh}/prompts $fpath)

# Homebrew
HOMEBREW_PREFIX=/opt/homebrew
if type ${HOMEBREW_PREFIX}/bin/brew &>/dev/null; then
	export HOMEBREW_NO_EMOJI=1
	export HOMEBREW_NO_ANALYTICS=1
	eval $(${HOMEBREW_PREFIX}/bin/brew shellenv)
	fpath+=($(brew --prefix)/share/zsh/site-functions $(brew --prefix)/share/zsh-completions)
fi

autoload -Uz compinit
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

# ===========
# Prompt
# ===========

# Default: PS1="%m%# "
declare +x PS1
prompt vcs

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

# Key mappings

# Emacs key mappings
bindkey -e

# Forward delete
bindkey "^[[3~" delete-char

# Editor
export EDITOR="vim"
export VISUAL="vim -g"
export LESSEDIT='vim ?lm+%lm. %f'
export TEXEDIT='vim +%d %s'

# less
export PAGER=less
export LESS="--status-column --long-prompt --no-init --quit-if-one-screen --quit-at-eof -R"

# ========================================
# Frameworks/Languages
# ========================================

# GitHub
if type gh &>/dev/null; then
	eval "$(gh completion -s zsh)"
fi

# Go
if type go &>/dev/null; then
	export PATH=$(go env GOPATH)/bin:${PATH}
fi

# Ruby
if type ruby &>/dev/null && type gem &>/dev/null; then
	export PATH=$(ruby -r rubygems -e 'puts Gem.user_dir')/bin:$PATH
fi

# Python
if [[ -d /Library/Frameworks/Python.framework/Versions/3.8 ]]; then
	export PATH=/Library/Frameworks/Python.framework/Versions/3.8/bin:${PATH}
fi
if [[ -d ${HOME}/Library/Python/3.8 ]]; then
	export LC_ALL=en_US.UTF-8
	export LANG=en_US.UTF-8
	export PATH=${HOME}/Library/Python/3.8/bin:${PATH}
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
	export PATH=${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${PATH}
fi

# Rust
if [[ -d ${HOME}/.cargo ]]; then
	export PATH=${HOME}/.cargo/bin:$PATH
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

if [ -f ${ZDOTDIR:-$DOTFILES/zsh}/zsh_aliases ]; then
    source ${ZDOTDIR:-$DOTFILES/zsh}/zsh_aliases
fi

# ========================================
# Path settings
# ========================================

# Add home bin dir if it is there
if [[ -d ${DOTFILES}/bin ]]; then
	export PATH=${DOTFILES}/bin:${PATH}
fi

# ========================================
# SSH
# ========================================

case $(uname) in
Linux )
	# Use keychain if installed
	if type keychain &>/dev/null; then
		eval `keychain --eval --agents ssh id_rsa id_ed25519`
	fi
	;;
esac

# ========================================
# Per-machine extras
# ========================================
if [[ -e ${HOME}/.zsh_local ]]; then
	source ${HOME}/.zsh_local
fi
