# Dotfiles configuration

dotfiles for POSIX operating systems

The dotfiles configuration works for macOS and Ubuntu/Pop Linux including WSL. It is untested with other Linux distributions but should be adaptable generally.

## Layout

* `bin` - useful scripts
* `conf` - configuration scripts symlinked in home directory
* `themes` - various theme files
* `zsh` - `${ZDOTDIR}` with zsh configuration

An optional install script is available to provision base packages and bootstrap dotfiles. Other scripts are available for installing packages for development and servers.

### Requirements

The following are the minimum requirements for dotfiles to work:

* [git](https://git-scm.com/download/linux)
* zsh

On macOS, [Xcode](https://itunes.apple.com/us/app/xcode/id497799835?mt=12) is expected to be installed and configured.

### Install

For convenience, a full install script can be run using the following command:

```sh
sh -c "$(curl -sSL https://raw.githubusercontent.com/ascarter/dotfiles/main/install.sh)"
```

### Alternate Install

If directly executing script is not desired, clone into a location (recommend `~/.config/dotfiles`)

```sh
git clone git@github.com:ascarter/dotfiles.git ~/.config/dotfiles
cd ~/.config/dotfiles
./install.sh
```

### Developer Tools

To optionally install developer tools, run the following shell script after installing dotfiles:

```sh
${DOTFILES}/developer.sh
```

### Server/Raspberry Pi Install

An install script for configuring some server packages can be run using the following command:

```sh
sh -c "$(curl -sSL https://raw.githubusercontent.com/ascarter/dotfiles/main/server.sh)"
```

Dotfiles is not required to run the server install script.

### Uninstall

Run the uninstall script to remove the symlinks:

```sh
cd ~/.config/dotfiles
./uninstall.sh
```
