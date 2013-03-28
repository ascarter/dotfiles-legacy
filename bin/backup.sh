#!/bin/sh

# Usage:
# backup.sh [source_dir] [dest]
# source == /Users/andrew
# dest   == /Volumes/MyDrive/backup (will copy to /Volumes/MyDrive/backup/andrew)

rsync -av --delete-excluded --exclude=${1}/Dropbox --exclude=${1}/.dropbox --exclude=${1}/Library/Caches "${1}" "${2}"
