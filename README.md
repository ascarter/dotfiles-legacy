# Dotfiles configuration

dotfiles for macOS, Linux, and Windows

## Layout

* `bin` - useful scripts
* `conf` - configuration scripts symlinked in home directory
* `powershell` - PowerShell configuration
* `themes` - various theme files
* `zsh` - `${ZDOTDIR}` with zsh configuration

An optional init script for each platform is available to install useful packages. Requirements are listed for each platform if the init script is not used. An install script to install development tools is available as well.

## Unix

The dotfiles configuration works for macOS and Ubuntu Linux including WSL. It is untested with other Linux distributions but should be adaptable generally.

### Requirements

The following are the minimum requirements for dotfiles to work:

* [git](https://git-scm.com/download/linux)
* zsh

On macOS, [Xcode](https://itunes.apple.com/us/app/xcode/id497799835?mt=12) is expected to be installed and configured. Optionally, [homebrew](https://brew.sh) is supported as well.

### Install

For convenience, a full install script can be run using the following command:

```sh
curl https://raw.githubusercontent.com/ascarter/dotfiles/main/dotfiles.sh | sh -
```

#### Manually Install

The `init.sh` script prepares the system for running the dotfiles install script. This is an optional system level configuration.

To run the provided init script:

```sh
curl https://raw.githubusercontent.com/ascarter/dotfiles/main/init.sh | sh -
```

To install dotfiles, run the following shell script:

```sh
curl https://raw.githubusercontent.com/ascarter/dotfiles/main/install.sh | sh -
```

To optionally install developer tools, run the following shell script:

```sh
curl https://raw.githubusercontent.com/ascarter/dotfiles/main/developer.sh | sh -
```

#### Alternate Install

If directly executing script is not desired, clone into a location (recommend `~/.config/dotfiles`)

```sh
git clone git@github.com:ascarter/dotfiles.git ~/.config/dotfiles
cd ~/.config/dotfiles
./init.sh
./install.sh
./developer.sh
```

#### Server/Raspberry Pi Install

An install script for configuring some server packages can be run using the following command:

```sh
curl https://raw.githubusercontent.com/ascarter/dotfiles/main/server.sh | sh -
```

### Uninstall

Run the uninstall script to remove the symlinks:

```sh
cd ~/.config/dotfiles
./uninstall.sh
```

## Windows

A PowerShell install script supports Windows 10.

### Pre-requisites

Enable [Developer mode](https://www.hanselman.com/blog/Windows10DeveloperMode.aspx):

*Settings* -> *Update & Security* -> *For Developers*

Additional requirements:

* [git](https://git-scm.com/download/win)
* [OpenSSH](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_overview)
* [Windows Subsystem for Linux 2](https://docs.microsoft.com/en-us/windows/wsl/wsl2-install)
* [PowerShell Core](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?view=powershell-7)
* [Windows Package Manager](https://github.com/microsoft/winget-cli)

To run the provided init script in elevated PowerShell (recommend Windows PowerShell terminal):

```powershell
Set-ExecutionPolicy Bypass -Scope Process; Invoke-WebRequest https://raw.githubusercontent.com/ascarter/dotfiles/main/init.ps1 -UseBasicParsing | Invoke-Expression
```

### Install

Run the following PowerShell script:

```powershell
Set-ExecutionPolicy Bypass -Scope Process; Invoke-WebRequest https://raw.githubusercontent.com/ascarter/dotfiles/main/install.ps1 -UseBasicParsing | Invoke-Expression
```

#### Alternate Install

If directly executing powershell script is not desired, clone into a location (recommend `%USERPROFILE%\.config\dotfiles`). Using elevated PowerShell:

```powershell
git clone git@github.com:ascarter/dotfiles.git $env:USERPROFILE\.config\dotfiles
cd $env:USERPROFILE\.config\dotfiles
.\install.ps1
```

### Uninstall

Run uninstall PowerShell script to remove links:

```powershell
cd $env:USERPROFILE\.config\dotfiles
.\uninstall.ps1
```
