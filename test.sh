#!/bin/sh
# Test script for dotfiles install
#
# Usage:
#	test.sh [target]
#
#	target == destination for dotfiles and homedir (default /tmp/dotfiles)
#

TESTDIR=${1:-/tmp/dotfiles}
DOTFILES=${TESTDIR}/config/dotfiles
HOMEDIR=${TESTDIR}/home

# Remove previous test run
rm -Rf ${DOTFILES} ${HOMEDIR}
sh install.sh ${DOTFILES} ${HOMEDIR}
