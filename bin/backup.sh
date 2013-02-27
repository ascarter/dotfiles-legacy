#!/bin/sh

rsync -av --delete --exclude=/Dropbox "${1}" "${2}"
