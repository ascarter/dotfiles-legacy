#  -*- mode: unix-shell-script; -*-

# Docker
# Remove stopped containers
alias dockerrms='docker rm $(docker ps -a -q)'
# Remove all untagged images
alias dockerrmi='docker rmi $(docker images | grep "^<none>" | awk "{print $3}")'
# Connect shell to default machine
alias dockerdefault='eval "$(docker-machine env default)"'
