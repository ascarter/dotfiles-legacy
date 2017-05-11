#  -*- mode: unix-shell-script; -*-

# Subverison
alias svnfmdiff='svn diff --diff-cmd /usr/local/bin/fmdiff'
alias svnfmmerge='svn merge --diff3-cmd /usr/local/bin/fmdiff3'
alias svnfmup='svn update --diff3-cmd /usr/local/bin/fmdiff3'
alias svnbbdiff='svn diff --diff-cmd bbdiff --extensions "--resume --wait --reverse"'
alias svnbbmerge='svn merge --diff3-cmd bbdiff'
alias svnbbup='svn update --diff3-cmd bbdiff'
