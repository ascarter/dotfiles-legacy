#  -*- mode: unix-shell-script; -*-

# Set JVM
set_jvm() {
	export JAVA_HOME=`/usr/libexec/java_home -v $1`
	java -version
}

alias java6="set_jvm 1.6"
alias java7="set_jvm 1.7"
alias java8="set_jvm 1.8"
alias java9="set_jvm 9"
alias java10="set_jvm 10"
alias java11="set_jvm 11"
alias java12="set_jvm 12"
