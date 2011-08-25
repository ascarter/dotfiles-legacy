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
# Functions/Completions
# ========================================

fpath=(~/.zsh/functions $fpath)
autoload -U compinit
compinit
autoload -U promptinit
promptinit
autoload -U colors
colors
autoload -U ~/.zsh/functions/[^_]*(:t)
autoload -Uz vcs_info

# ========================================
# Languages/frameworks
# ========================================

# Ruby (rbenv)
if [ -d ~/.rbenv/bin ]; then
    export PATH=~/.rbenv/bin:${PATH}
	eval "$(rbenv init -)"
fi

# Python
export WORKON_HOME=$HOME/.virtualenvs
if [[ -s /usr/local/bin/virtualenvwrapper.sh ]] ; then
    source /usr/local/bin/virtualenvwrapper.sh
fi

# Java

# Android
# export M2_HOME=/usr/local/apache-maven/apache-maven-3.0
# export M2=${M2_HOME}/bin
# export MAVEN_OPTS="-Xms256m -Xmx512m"
# export PATH=${M2}:${PATH}
export ANDROID_SDK=~/Developer/Library/Android/android-sdk-mac_x86
export ANDROID_HOME=${ANDROID_SDK}
export ANDROID_NDK=~/Developer/Library/Android/android-ndk-r5
export PATH=${PATH}:${ANDROID_SDK}/tools:${ANDROID_SDK}/platform-tools

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
    export EDITOR="vim"
    export GIT_EDITOR="${EDITOR}"
    export SVN_EDITOR="${EDITOR}"
    export VISUAL="gvim"
    export LESSEDIT='vim ?lm+%lm. %f'
    export TEXEDIT='vim +%d %s'
fi

# zstyle ':completion:*' verbose yes
# zstyle ':completion:*:descriptions' format '%B%d%b'
# zstyle ':completion:*:messages' format '%d'
# zstyle ':completion:*:warnings' format 'No matches for: %d'
# zstyle ':completion:*' group-name ”

# ========================================
# Terminal settings
# ========================================

# Set directory colors

# Default (light shell)
# export LSCOLORS=exfxcxdxbxegedabagacad

# Dark shell
export LSCOLORS=gxfxcxdxbxegedabagacad

# ========================================
# Prompt
# ========================================

setopt transient_rprompt

# Default
# PS1="%m%# "
declare +x PS1
prompt ascartervcs

# ========================================
# Aliases
# ========================================
if [ -e ~/.zsh_aliases ]; then
	. ~/.zsh_aliases
fi
