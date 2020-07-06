#!/bin/sh

# Add Microsoft apt repository
# https://docs.microsoft.com/en-us/dotnet/core/install/linux-ubuntu
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb

# Add nodesource repository
# https://github.com/nodesource/distributions
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -

# Add yarn package manager repository
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# Update repositories and packages
sudo apt-get update
sudo apt-get install -y apt-transport-https
sudo apt-get update
sudo apt-get upgrade -y

# Install developer packages
sudo apt-get install -y build-essential dotnet-sdk-3.1 golang nodejs openjdk-14-jdk python3 python3-dev python3-pip yarn

# Install latest Go since Ubuntu release is behind and snap not supported
GO_VERSION=1.14.4
if ! [ -x "$(command -v go${GO_VERSION})" ]; then
    go get golang.org/dl/go${GO_VERSION}
    go${GO_VERSION} download
fi
