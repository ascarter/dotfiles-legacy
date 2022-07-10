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
        Ubuntu | Pop )
            CODENAME=$(lsb_release -s -c)

            # Add Tailscale repository
            curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/${CODENAME}.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
            curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/${CODENAME}.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list

            sudo apt-get update
            sudo apt-get install -y tailscale

            # Authenticate and connect to Tailscale network
            sudo tailscale up
            ;;
        esac
    esac
fi

tailscale ip
