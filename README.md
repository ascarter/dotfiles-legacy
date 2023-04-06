# Dotfiles configuration

dotfiles for POSIX operating systems

The dotfiles configuration works for macOS and Ubuntu/Pop Linux including WSL. It is untested with other Linux distributions but should be adaptable generally.

There is also a [PowerShell module](powershell/README.md) that enables similar command line extensions for PowerShell. It is tested for Windows 10/11 and untested for Linux PowerShell.

# Layout

* `bin` - useful scripts
* `conf` - configuration scripts symlinked in home directory
* `powershell` - PowerShell support
* `themes` - various theme files
* `zsh` - `${ZDOTDIR}` with zsh configuration

An optional install script is available to provision base packages and bootstrap dotfiles. Other scripts are available for installing packages for development and servers.

# Requirements

The following are the minimum requirements for dotfiles to work:

* [git](https://git-scm.com/download/linux)
* zsh

On macOS, [Xcode](https://itunes.apple.com/us/app/xcode/id497799835?mt=12) is expected to be installed and configured.

On Windows, PowerShell 7.0+ is expected.

# Install

Install scripts are available for Unix and Windows systems.

## Unix

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

### Additional Install Scripts

The `scripts` directory contains several additional install scripts. Run based on your usage scenario:

| Script | Description |
| ------ | ----------- |
| `scripts/server.sh` | Server tools targetting Ubuntu Server and Raspberry Pi |
| `scripts/test.sh` | Dotfiles test suite |
| `scripts/virt.sh` | Enable virtualisation for macOS and Ubuntu (KVM and Docker) |
| `scripts/workstation.sh` | Workstation applications and tools for macOS and Ubuntu/Pop OS |
| `scripts/wsl.sh` | WSL software tools on Ubuntu |


### Uninstall

Run the uninstall script to remove the symlinks:

```sh
cd ~/.config/dotfiles
./uninstall.sh
```

## Windows

See [README](powershell/README.md) for instructions for installing in Windows PowerShell environment.
