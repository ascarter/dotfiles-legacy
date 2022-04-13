# Get one-time password for item from 1Password

emulate -L zsh

op get totp "${1}" | tr -d '\n' | pbcopy
