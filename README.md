# Dotfiles configuration

This is my collection of dotfiles for macOS, Linux, and Windows

## Layout

* `bin` - useful scripts
* `themes` - various theme files
* `zsh` - `${ZDOTDIR}` with zsh configuration

## Unix

The dotfiles configuration works for macOS and Ubuntu Linux (possibly other Linux distros)

### Install

Run the following shell script:

```
% sh -c "$(curl https://raw.githubusercontent.com/ascarter/dotfiles/master/install.sh)"
```

#### Alternate Install

If directly executing script is not desired, clone into a location (recommend `~/.config/dotfiles`)

```
% git clone git@github.com:ascarter/dotfiles.git ~/.config/dotfiles
% cd ~/.config/dotfiles
% ./install.sh
```

### Uninstall

Run the uninstall script to remove the symlinks:

```
% cd ~/.config/dotfiles
% ./uninstall.sh
```

## Windows

A PowerShell install script supports Windows 10. It is meant to run on a fresh Windows 10 install with Windows PowerShell version 5. It should also work if run from PowerShell Core 6+.

### Pre-requisites

Enable [Developer mode](https://www.hanselman.com/blog/Windows10DeveloperMode.aspx):

*Settings* -> *Update & Security* -> *For Developers*

### Install

Run the following powershell script from elevated powershell:

```
PS[Admin]> Set-ExecutionPolicy Bypass -Scope Process; Invoke-WebRequest https://raw.githubusercontent.com/ascarter/dotfiles/master/install.ps1 -UseBasicParsing | Invoke-Expression
```

#### Alternate Install

If directly executing powershell script is not desired, clone into a location (recommend `%USERPROFILE%\.config\dotfiles`). Using elevated powershell:

```
PS[ADMIN]> git clone git@github.com:ascarter/dotfiles.git $env:USERPROFILE\.config\dotfiles
PS[ADMIN]> cd $env:USERPROFILE\.config\dotfiles
PS[ADMIN]> .\install.ps1
```

### Uninstall

Run uninstall powershell script to remove links:

```
PS[ADMIN]> cd $env:USERPROFILE\.config\dotfiles
PS[ADMIN]> .\uninstall.ps1
