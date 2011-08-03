# Terminal
alias ls='ls -hFGH'
alias ll='ls -l'
alias la='ls -a'

# Search/grep
alias devgrep="grep -n -r --exclude='.svn' --exclude='*.swp' --exclude='.git'"

# System shortcuts
alias loginw='/System/Library/CoreServices/"Menu Extras"/User.menu/Contents/Resources/CGSession -suspend'

# Power managment
alias sleepnow='pmset sleepnow'

# QuickLook
alias ql='qlmanage -p "$@" >& /dev/null'

# Dev tools
alias bbtags='bbedit --maketags'
alias eclipse='open /Developer/Applications/Eclipse.app'

# Subverison
alias svnfmdiff='svn diff --diff-cmd /usr/local/bin/fmdiff'
alias svnfmmerge='svn merge --diff3-cmd /usr/local/bin/fmdiff3'
alias svnfmup='svn update --diff3-cmd /usr/local/bin/fmdiff3'

alias svnbbdiff='svn diff --diff-cmd bbdiff --extensions "--resume --wait --reverse"'
alias svnbbmerge='svn merge --diff3-cmd bbdiff'
alias svnbbup='svn update --diff3-cmd bbdiff'

# Python
alias rmpyc='find . -type f -name \*.pyc -print | xargs rm'
alias pydocv='python -m pydoc'

# Shortcuts
alias projects='cd ~/Developer/Projects'
alias dev='cd ~/Developer'
