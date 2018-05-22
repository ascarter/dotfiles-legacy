#  -*- mode: unix-shell-script; -*-

# dotfiles home folder
alias dotf='cd ~/.dotfiles'

# ls
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lsd="ls -l | grep --color=never '^d'"
alias lsz="ls -lAh | grep -m 1 total | sed 's/total //'"

# up 'n' folders
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias filetree="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/ /' -e 's/-/|/'"

# Search/grep
alias devgrep="grep -n -r --exclude='.svn' --exclude='*.swp' --exclude='.git'"

# Ski
alias whistlertom='curl -o ~/Documents/whistler_tom.pdf -L "http://online.whistlerblackcomb.com/TomPDF/Default.aspx?Season=1&Type=bg" && ql ~/Documents/whistler_tom.pdf'

# Stopwatch
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'

# Intuitive map function
# For example, to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname
alias map="xargs -n1"

# Canonical hex dump; some systems have this symlinked
command -v hd > /dev/null || alias hd="hexdump -C"

# 1Password signin
alias opsignin='eval $(op signin carters)'
