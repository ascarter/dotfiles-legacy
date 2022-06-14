# Run command and send results to bbresults
# filters any leading whitespace

emulate -L zsh

($* 2>&1) | sed -e 's/^[ \t]*//' | bbresults --errors-default
