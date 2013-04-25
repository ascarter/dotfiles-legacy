# ========================================
# Path settings
# ========================================

# Add developer bin
if [ -d ~/Developer/bin ]; then
	export PATH=~/Developer/bin:${PATH}
fi


# Add home bin dir if it is there
if [ -d ~/.bin ]; then
	export PATH=~/.bin:${PATH}
fi

# ========================================
# Shell preferences
# ========================================

# Editor

if [ -e /usr/local/bin/bbedit ]; then
    # bbedit
    export GIT_EDITOR="bbedit -w"
    export SVN_EDITOR="bbedit -w"
    export EDITOR="bbedit -w"
    export VISUAL="bbedit"
    export LESSEDIT='bbedit -l %lm %f'
    export TEXEDIT='bbedit -w -l %d "%s"'
else
    # vim
    export EDITOR="mvim"
    export GIT_EDITOR="${EDITOR} --nofork"
    export SVN_EDITOR="${EDITOR} --nofork"
    export VISUAL="mvim"
    export LESSEDIT='vim ?lm+%lm. %f'
    export TEXEDIT='vim +%d %s'
fi

# less
export PAGER=less
export LESS="--status-column --long-prompt --no-init --quit-if-one-screen --quit-at-eof -R"

# Command history
bind '"[A":history-search-backward'
bind '"[B":history-search-forward'

# ========================================
# Languages/frameworks
# ========================================

# Homebrew
export HOMEBREW_NO_EMOJI=1

# Ruby (rbenv)
if [ -d ~/.rbenv ]; then
	export PATH=~/.rbenv/bin:${PATH}
	eval "$(rbenv init -)"
fi

# Add local bin directory for Ruby/Bundler
export PATH=./bin:${PATH}

# Python
export WORKON_HOME=$HOME/.virtualenvs
if [[ -s /usr/local/bin/virtualenvwrapper.sh ]] ; then
    source /usr/local/bin/virtualenvwrapper.sh
fi

# Java
if [[ -e /usr/libexec/java_home ]] ; then
	export JAVA_HOME=`/usr/libexec/java_home -v 1.7`
fi

# Android
export ANDROID_HOME=~/Developer/Library/Android
export ANDROID_SDK=${ANDROID_HOME}/adt-bundle-mac-x86_64/sdk
export ANDROID_NDK=${ANDROID_HOME}/android-ndk-r8d
export PATH=${PATH}:${ANDROID_SDK}/tools:${ANDROID_SDK}/platform-tools

# Node
export NODE_PATH=/usr/local/lib/node_modules

# Perforce
export P4DIFF=/usr/local/bin/ksdiff
export P4MERGE=/usr/local/bin/ksdiff

# ========================================
# Applications/services
# ========================================

export POSTGRES_APP_ROOT=/Applications/Postgres.app/Contents/MacOS
if [ -d ${POSTGRES_APP_ROOT} ]; then
    export PATH=${POSTGRES_APP_ROOT}/bin:${PATH}
fi

# Heroku Toolbelt
if [ -d /usr/local/heroku ]; then
	export PATH="/usr/local/heroku/bin:$PATH"
fi

# ========================================
# Shell functions
# ========================================

# Set terminal title
function title() {
  PROMPT_COMMAND="echo -ne \"\033]0;$*\a\""
}

# Set title to string
function etitle() {
  title "\$(eval \"$*\")"
}

# Set title to current directory
function pwdtitle() {
  title "${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~} \$(__dev_ps1 '— (%s)')"
}

# Return text to add to bash PS1 prompt for active rbenv
function __rbenv_ps1() {
	if [ -d ~/.rbenv ]; then
		local rbenv_ps1="$(rbenv version-name)"
		if [ -n "${rbenv_ps1}" ]; then
			if [ "system" != "${rbenv_ps1}" ]; then
				printf "${1:-%s}" "$rbenv_ps1"
			fi
		fi
	fi
}

# Return text to add to bash PS1 prompt for active virtual env
function __virtualenv_ps1() {
    local virtualenv_ps1="`basename \"${VIRTUAL_ENV}\"`"
    if [ -n "${virtualenv_ps1}" ]; then
        printf "${1:-%s}" "$virtualenv_ps1"
    fi
}

# Return a developer prompt
# Arguments:
#   $1 = all format string
#   $2 = rbenv format
#   $3 = Virtualenv format
#   $4 = Git format
#   $5 = Separator
function __dev_ps1() {
    local format="${1:-%s}"
    local rbenv_format="${2:-%s}"
    local virtualenv_format="${3:-%s}"
    local git_format="${4:-%s}"
    local separator="${5:-|}"
    shift 5

    local rbenv_ps1="$(__rbenv_ps1 ${rbenv_format})"
    local virtualenv_ps1="$(__virtualenv_ps1 ${virtualenv_format})"
    local git_ps1="$(__git_ps1 ${git_format})"

    # Build format string
    dev_ps1=
    for element in ${rbenv_ps1##*( )} ${virtualenv_ps1##*( )} ${git_ps1##*( )}
    do
        if [ -n "$element" ]; then
            if [ -n "$dev_ps1" ]; then
                dev_ps1="${dev_ps1}${separator}"
            fi
            dev_ps1="${dev_ps1}${element}"
        fi
    done
    if [ -n "$dev_ps1" ]; then
        printf "$format" "$dev_ps1"
    fi
}

# Open gem doc page
function gemdoc {
    open "http://localhost:8808/rdoc?q=$1"
}

# Open man page with default x-man handler
# On Mac OS X, opens a nice terminal window
function manx() {
   open x-man-page://${1}
}

# Switch to project home
function project() {
    cd ~/Developer/Projects/${1}
}

# Open URL source in BBEdit
function bbcurl () {
    curl $1 | bbedit --new-window +1 -t $1
}


# ========================================
# Terminal settings
# ========================================

# Colors
COLOR_CLEAR="\[\033[0m\]"
COLOR_BLACK="\[\033[0;30m\]"
COLOR_RED="\[\033[0;31m\]"
COLOR_GREEN="\[\033[0;32m\]"
COLOR_YELLOW="\[\033[0;33m\]"
COLOR_BLUE="\[\033[0;34m\]"
COLOR_MAGENTA="\[\033[0;35m\]"
COLOR_CYAN="\[\033[0;36m\]"
COLOR_WHITE="\[\033[0;37m\]"

COLOR_BOLD_BLACK="\[\033[1;30m\]"
COLOR_BOLD_RED="\[\033[1;31m\]"
COLOR_BOLD_GREEN="\[\033[1;32m\]"
COLOR_BOLD_YELLOW="\[\033[1;33m\]"
COLOR_BOLD_BLUE="\[\033[1;34m\]"
COLOR_BOLD_MAGENTA="\[\033[1;35m\]"
COLOR_BOLD_CYAN="\[\033[1;36m\]"
COLOR_BOLD_WHITE="\[\e[1;37m\]"

COLOR_BACKGROUND_BLACK="\[\033[40m\]"
COLOR_BACKGROUND_RED="\[\033[41m\]"
COLOR_BACKGROUND_GREEN="\[\033[42m\]"
COLOR_BACKGROUND_YELLOW="\[\033[43m\]"
COLOR_BACKGROUND_BLUE="\[\033[44m\]"
COLOR_BACKGROUND_MAGENTA="\[\033[45m\]"
COLOR_BACKGROUND_CYAN="\[\033[46m\]"
COLOR_BACKGROUND_WHITE="\[\033[47m\]"

# Prompt
declare +x PS1

if [ $TERM = "xterm-256color" -o $TERM = "xterm-color" -o $TERM = "dtterm" -o $TERM = "linux" ]; then
  export CLICOLOR=1
  PS1="\$(__dev_ps1 '(${COLOR_BOLD_CYAN}%s${COLOR_CLEAR})')${COLOR_WHITE}\u@\h:${COLOR_BOLD_WHITE}\W${COLOR_CLEAR}\$ "
  pwdtitle
else
  PS1='\[\e]2;\u@\h: \w\a\][\u@\h:\W$(__dev_ps1 " (%s)")]\$ '
fi

# Set directory colors
# man ls -> find LSCOLORS

# Default (light terminal)
# export LSCOLORS=exfxcxdxbxegedabagacad

# Dark terminal
# export LSCOLORS=gxfxcxdxbxegedabagacad

# Daring Fireball terminal
export LSCOLORS=CxGxcxdxBxegedabagacad

# ========================================
# Aliases
# ========================================
if [ -e ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

# ========================================
# Bash completions
# ========================================

# Homebrew - will also call user's ~/.bash_completion too
if [ -n "`which brew`" ]; then
    if [ -f `brew --prefix`/etc/bash_completion ]; then
        . `brew --prefix`/etc/bash_completion
    fi
fi

if [ -e ~/.bash_completion ]; then
    . ~/.bash_completion
fi

# Pip
if [ -n "`which pip`" ]; then
	eval "`pip completion --bash`"
fi

# ========================================
# Shell methods
# ========================================
function gemdoc {
    open "http://localhost:8808/rdoc?q=$1"
}

# ========================================
# Per-machine extras
# ========================================
if [ -e ~/.bash_local ]; then
	. ~/.bash_local
fi
