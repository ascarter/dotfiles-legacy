# Terminal
alias ls='ls -hFGH'
alias ll='ls -l'
alias la='ls -a'
alias fc='find . -type f | wc -l'

# Command line aliases
alias devgrep="grep -n -r --exclude='.svn' --exclude='*.swp' --exclude='.git'"

# System shortcuts
alias loginw='/System/Library/CoreServices/"Menu Extras"/User.menu/Contents/Resources/CGSession -suspend'

# Power managment
alias sleepnow='pmset sleepnow'

# Application aliases
# alias vim="vim -p"
# alias vim="/usr/local/bin/vim"
alias firefox="/Applications/Firefox.app/Contents/MacOS/firefox"
alias firefoxn="/Applications/Firefox.app/Contents/MacOS/firefox-bin file://$PWD/$* &"
alias preview="open /Applications/Preview.app "
alias textedit='open -e'
alias ql='qlmanage -p "$@" >& /dev/null'
alias vmrun="/Library/Application\ Support/VMware\ Fusion/vmrun"

# Temp/Hardware monitors
alias tempmonitor="/Applications/Utilities/TemperatureMonitor.app/Contents/Resources/tempmonitor"
alias hwmonitor="/Applications/Utilities/HardwareMonitor.app/Contents/Resources/hwmonitor"

# procfs
alias procfsmount="sudo /usr/local/bin/procfs /proc"
alias procfsumount="sudo umount /proc"
alias procfsreset="cd /; sudo umount /proc; sudo /usr/local/bin/procfs /proc; cd /proc"

# MySQL
alias start_mysql="sudo /Library/StartupItems/MySQLCOM/MySQLCOM start"
alias stop_mysql="sudo /Library/StartupItems/MySQLCOM/MySQLCOM stop"

# Dev tools
alias eclipse='open /Developer/Applications/Eclipse.app'

# Subverison
alias svngdiff='svn diff --diff-cmd /usr/local/bin/fmdiff'
alias svngmerge='svn merge --diff3-cmd /usr/local/bin/fmdiff3'
alias svngup='svn update --diff3-cmd /usr/local/bin/fmdiff3'

# alias svngdiff='svn diff --diff-cmd=ksdiff-svnwrapper'
#alias svngmerge='svn merge --diff3-cmd=ksdiff-svnwrapper'
# alias svngup='svn update --diff3-cmd=ksdiff-svnwrapper'

# Git
alias gitsvnup='GIT_BRANCH=$(__git_ps1 "%s"); git checkout master; git svn rebase ; git checkout ${GIT_BRANCH} ; git rebase master'
#alias github="open `git config -l | grep 'remote.origin.url' | sed -n 's/remote.origin.url=git@github.com:\(.*\)\/\(.*\).git/https:\/\/github.com\/\1\/\2/p'`"
# alias gitchdiff='GIT_EXTERNAL_DIFF=~/bin/gitchdiff.sh git diff'
# alias gitfmdiff='GIT_EXTERNAL_DIFF=~/bin/gitfmdiff.sh git diff'
