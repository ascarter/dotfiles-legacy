#  -*- mode: unix-shell-script; -*-

# Python
alias rmpyc='find . -type f -name \*.pyc -print | xargs rm'
alias pydocv='python -m pydoc'
alias editvenv='bbedit --new-window ${VIRTUAL_ENV}'
alias pipbrew='CFLAGS="-I/opt/homebrew/include -L/opt/homebrew/lib" pip'
alias pdb='python -m pdb'
alias pyunittest='python -m unittest discover --buffer'
