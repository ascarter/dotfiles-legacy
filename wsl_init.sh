#!/bin/sh
#
# Initialize WSL environment

case "$(uname)" in
Linux )
	if [ -z "${WSL_DISTRO_NAME}" ]; then
		echo "Not WSL environment"
		return
	fi

	DISTRO_DESCRIPTION=$(lsb_release -d -s)
	case $(lsb_release -i -s) in
	Ubuntu )
		echo "Initializing WSL on ${DISTRO_DESCRIPTION}"
		# Update distro
		sudo apt update
		sudo apt upgrade -y

		# Install packages
		sudo apt install build-essential zsh keychain
		;;
	*)
		echo "Unknown Linux disto ${DISTRO_DESCRIPTION}"
		return
		;;
	esac

	# Install latest Go
	if ! command -v go >/dev/null 2>&1; then
		GO_PKG=https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz
		curl -L ${GO_PKG} | sudo tar -C /usr/local -xz
		sudo ln -s /usr/local/go/bin/go /usr/local/bin/go
		sudo ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt
	fi
	go version

	# Configure SSH
	for pubkey in /mnt/c/Users/${USER}/.ssh/id_*.pub; do
		privkey=$(dirname ${pubkey})/$(basename -s .pub ${pubkey})
		echo "chmod ${privkey}"
		chmod 0600 ${privkey}
	done

	# Configure WSL
	if ! [ -e /etc/wsl.conf ]; then
		echo "Generate WSL conf"
		sudo tee /etc/wsl.conf > /dev/null <<EOF
[automount]
enabled = true
options = "metadata"
EOF
	fi
	;;
*) echo "Not Linux environment" ;;
esac
