# Unix configuration

This is my collection of dotfiles

## Layout

* `bin` - useful scripts
* `home` - files that are symlinked to `${HOME}`
* `zsh` - `${ZDOTDIR}` with zsh configuration

## Install

Run the following shell script to link files in `home` and run configuration for git and zsh:

```
% sh -c "$(curl https://raw.githubusercontent.com/ascarter/dotfiles/master/install.sh)"
```

Alternatively:

* Clone into a location (recommend `~/.config/dotfiles`)

After the enlistment is created:

```
% cd ~/.config/dotfiles
% ./install.sh
```

## Uninstall

Run the uninstall script to remove the symlinks:

```
% cd ~/.config/dotfiles
% ./uninstall.sh
```