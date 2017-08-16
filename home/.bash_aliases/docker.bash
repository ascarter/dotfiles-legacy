#  -*- mode: unix-shell-script; -*-

# Docker aliases

# Remove stopped containers
alias dockerrms='docker rm $(docker ps -a -q)'

# Remove all untagged images
#alias dockerrmi='docker rmi $(docker images -q --filter "dangling=true")'

# List untagged images
alias dockeruntagged='docker images --filter "dangling=true"'
