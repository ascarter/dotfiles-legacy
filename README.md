# Unix configuration

This is my collection of configuration scripts for bash, git, etc.

## Install

There is a 2-phase installer. The first part is to bootstrap a new system to have all the configuration files present and to configure important software like Git. The next phase is to automate installing software combinations.

Most software is managed by [Homebrew](https://brew.sh).

To bootstrap:

```
$ curl https://raw.githubusercontent.com/ascarter/dotfiles/master/install.sh | sh
```

Alternatively:

* Install Xcode from Mac App Store
* Install Xcode command line tools with `xcode-select --install`
* Clone into a location (recommend `~/.dotfiles`)

After the enlistment is created:

```
$ cd ~/.dotfiles
$ rake
```

Re-run will check for identical files and prompt if a replace will occur. Replace preserves existing file in `file.orig`
