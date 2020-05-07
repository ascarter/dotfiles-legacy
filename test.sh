#!/bin/sh
# Test script for dotfiles install
#
# Usage:
#	test.sh [target]
#
#	target == destination for dotfiles and homedir (default /tmp/dotfiles)
#

TESTDIR=${1:-/tmp/dotfiles}
HOMEDIR=${TESTDIR}/home
DOTFILES=${TESTDIR}/config/dotfiles

# Remove previous test run
rm -Rf ${DOTFILES} ${HOMEDIR}
sh install.sh ${HOMEDIR} ${DOTFILES}
