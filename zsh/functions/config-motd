emulate -L zsh

# Configure motd
#
#   config-motd
#

case "$(uname)" in
Linux )
    if [ -d /etc/update-motd.d ]; then
        # Disable Ubuntu news
        # TODO: sed comment out Ubuntu news

        # Add motd script symlinks
        motd_dir=~/.config/motd
        if [ -d ${motd_dir} ]; then
            for f in $(find ${motd_dir} -type f,l -print); do
                t=/etc/update-motd.d/${f#${motd_dir}/}
                if ! [ -h ${t} ]; then
                    # Check if file is already there and preserve
                    if [ -e ${t} ]; then
                        echo "Backup existing file ${t} -> ${t}.orig"
                        sudo mv ${t} ${t}.orig
                    fi

                    # Create symlink
                    echo "symlink ${f} -> ${t}"
                    sudo ln -s ${f} ${t}

                    # Enable motd script
                    sudo chmod +x ${t}
                fi
            done
        fi

        # Update motd
        sudo update-motd
    fi
    ;;
esac
