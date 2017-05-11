#!/bin/sh

# Output colors: http://linuxtidbits.wordpress.com/2008/08/11/output-color-on-bash-scripts/
for i in $(seq 0 $(tput colors)); do
	echo " $(tput setaf $i)Text$(tput sgr0) $(tput bold)$(tput setaf $i)Text$(tput sgr0) $(tput sgr 0 1)$(tput setaf $i)Text$(tput sgr0)  \$(tput setaf $i)"
done
