#!/bin/sh

# Enable Tailscale

set -ue

if ! [ -x "$(command -v tailscale)" ]; then
    case "$(uname)" in
    Darwin )
        brew install mas
        mas install 1475387142
        ;;
    Linux )
        case $(lsb_release -i -s) in
        Ubuntu | Pop | Raspbian )
            ID=$(lsb_release -i -s | tr "[:upper:]" "[:lower:]")
            CODENAME=$(lsb_release -s -c)

            if [ "${ID}" = "pop" ]; then
                ID="ubuntu"
            fi

            sudo apt-get install -y apt-transport-https

            # Add Tailscale repository
            curl -fsSL https://pkgs.tailscale.com/stable/${ID}/${CODENAME}.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
            curl -fsSL https://pkgs.tailscale.com/stable/${ID}/${CODENAME}.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list

            sudo apt-get update
            sudo apt-get install -y tailscale

            # Authenticate and connect to Tailscale network
            sudo tailscale up

            echo "Tailscale installed"
            tailscale ip
            ;;
        esac
    esac
fi
