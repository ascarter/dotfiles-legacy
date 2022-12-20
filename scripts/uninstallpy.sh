#!/bin/sh

# This script will uninstall all the versions of Python 3.x
# on your macOS system
#
# To run a dry run, do
#
#   bash uninstallpy.sh
#
# Examine the output - make sure that it is moving only the expected
# files.  When you are convinced this will do what you expect run
#
#   bash uninstallpy.sh | sudo bash -v
#
# To verify the files are gone, you can re-run
#
#   bash uninstallpy.sh
#
# It should produce no output.
#

ls -l /usr/local/bin | grep /Library/Frameworks/Python.framework/Versions/3 | awk '{print "rm \47/usr/local/bin/" $9 "\47"}'
ls -d /Library/Frameworks/Python.framework/Versions/3.* 2> /dev/null | awk '{print "rm -rf \47" $0 "\47"}'
ls -d /Applications/Python\ 3.* 2> /dev/null | awk '{print "rm -rf \47" $0 "\47"}'
