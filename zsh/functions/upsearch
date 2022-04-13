emulate -L zsh

# Search up path until target directory is found
upsearch() {
    local P=$(pwd)
    while [[ "$P" != "" && ! -e "$P/$1" ]]; do
        P=${P%/*}
    done
    print "$P"
}

