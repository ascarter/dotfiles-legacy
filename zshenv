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
# Languages/frameworks
# ========================================

# Homebrew
export HOMEBREW_NO_EMOJI=1

# Ruby (rbenv)
if [ -d ~/.rbenv/bin ]; then
    export PATH=~/.rbenv/bin:${PATH}
	eval "$(rbenv init -)"
fi

# Add local bin directory for Ruby/Bundler
export PATH=./bin:${PATH}

# Python
export WORKON_HOME=$HOME/.virtualenvs
if [[ -e /usr/local/bin/virtualenvwrapper.sh ]] ; then
    source /usr/local/bin/virtualenvwrapper.sh
fi

# Java

# Android
export ANDROID_HOME=~/Developer/Library/Android
export ANDROID_SDK=${ANDROID_HOME}/adt-bundle-mac-x86_64/sdk
export ANDROID_NDK=${ANDROID_HOME}/android-ndk-r8d
export PATH=${PATH}:${ANDROID_SDK}/tools:${ANDROID_SDK}/platform-tools

# Node
export NODE_PATH=/usr/local/lib/node_modules

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
