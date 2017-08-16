#  -*- mode: unix-shell-script; -*-

# Docker aliases

# Remove stopped containers
alias dockerrms='docker rm $(docker ps -a -q)'

# List untagged images
alias dockeruntagged='docker images --filter "dangling=true"'
