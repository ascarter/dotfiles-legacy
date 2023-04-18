# Open URL source in BBEdit

emulate -L zsh

(curl "$@") | bbedit --clean --view-top -t "curl ${@[$#]}"
