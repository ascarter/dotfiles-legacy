# ========================================
# Path settings
# ========================================

# Add developer bin
if [ -d ~/Developer/bin ]; then
	PATH=~/Developer/bin:${PATH}
fi


# Add home bin dir if it is there
if [ -d ~/.bin ]; then
	PATH=~/.bin:${PATH}
fi

# rbenv
if [ -d ~/.rbenv/bin ]; then
    PATH=~/.rbenv/bin:${PATH}
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
    export EDITOR="vim"
    export GIT_EDITOR="${EDITOR}"
    export SVN_EDITOR="${EDITOR}"
    export VISUAL="gvim"
    export LESSEDIT='vim ?lm+%lm. %f'
    export TEXEDIT='vim +%d %s'
fi

# ========================================
# Languages/frameworks
# ========================================

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

# Ruby
if [ -d ~/.rbenv ]; then
	eval "$(rbenv init -)"
fi

# ========================================
# Terminal settings
# ========================================

# Set directory colors

# Default (light shell)
# export LSCOLORS=exfxcxdxbxegedabagacad

# Dark shell
export LSCOLORS=gxfxcxdxbxegedabagacad


# ========================================
# Aliases
# ========================================
if [ -e ~/.zsh_aliases ]; then
	. ~/.zsh_aliases
fi

# ========================================
# Functions/Completions
# ========================================

fpath=(~/.zsh/functions ~/.rbenv/completions $fpath)
autoload -U compinit
compinit
autoload -- ~/.zsh/functions/[^_]*(:t)

