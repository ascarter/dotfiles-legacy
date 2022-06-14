# Run rubocop and send results to bbresults

emulate -L zsh

(rubocop --format emacs "$@") | bbresults -p "(?P<file>.+?):(?P<line>\d+):(?P<col>\d+):\s+(?P<type>[CWEF]):\s+(?P<msg>.*)$"
