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
# export M2_HOME=/usr/local/apache-maven/apache-maven-3.0
# export M2=${M2_HOME}/bin
# export MAVEN_OPTS="-Xms256m -Xmx512m"
# export PATH=${M2}:${PATH}
export ANDROID_SDK=~/Developer/Library/Android/android-sdk-mac_x86
export ANDROID_HOME=${ANDROID_SDK}
export ANDROID_NDK=~/Developer/Library/Android/android-ndk-r5
export PATH=${PATH}:${ANDROID_SDK}/tools:${ANDROID_SDK}/platform-tools

# Node
export NODE_PATH=/opt/homebrew/lib/node_modules

