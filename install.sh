#!/bin/sh

# Install dotfile support to user account
#
# Author: Andrew Carter (ascarter@fastmail.net)
#

TARGET_DIR=${1:-$HOME}
echo "Installing dotfiles to ${TARGET_DIR}..."

# Bootstrap
bootstrap() {
	replace_all='false'
	
	for file in *; do
		filename=${file%.erb}
		case $filename in
		install.sh|Rakefile|README.md)
			echo "--> Skip ${filename}"
			;;
		*)
			target=${TARGET_DIR}/.${filename}
			if [ -e ${target} ]; then
				if diff --brief $filename $target; then
					echo "Identical ${filename}"
				else
					echo "need to replace ${filename}"
					if $replace_all == 'true'; then
						replace_file $file $target
					else
						echo "Replace existing file ${filename}? [ynaq] "
						read answer
						case $answer in
						a)
							replace_all='true'
							replace $file $target
							;;
						y)
							replace $file $target
							;;
						q)
							echo "Abort"
							exit
							;;
						*)
							echo "Skipping ${filename}"
							;;
						esac
					fi
				fi
			else
				symlink_file $file $target
			fi
			;;
		esac
	done
}

# chsh
install_chsh() {
	case $SHELL in
	*/zsh)
		echo "User's shell is zsh"
		;;
	*)
		echo "Setting user's shell to zsh..."
		chsh -s /bin/zsh
		;;
	esac
}

# rbenv

# homebrew

# virtualenv

# vim

# Helpers

replace_file() {
	file=$1
	target=$2
	backup=${target}.orig
	echo "Backing up ${target} to ${backup}"
	cp ${target} ${backup}
	symlink_file $file $target
}

symlink_file() {
	file=$1
	target=$2
	filename=${file%.erb}
	case $file in
	*/.erb)
		echo "Generating ${filename}"
		;;
	*)
		echo "Symlink ${file}"
		ln -s ${file} ${target}
		;;
	esac
}

########################################
# MAIN
########################################

bootstrap
install_chsh