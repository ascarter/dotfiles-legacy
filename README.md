# Unix configuration

This is my collection of configuration scripts for bash, git, etc.

## Install

There is a 2-phase installer. The first part is to bootstrap a new system to have all the configuration files present and to configure important software like Git. The next phase is to automate installing software combinations.

Most software is managed by [Homebrew](https://brew.sh).

To bootstrap:

```
$ ruby -e "$(curl https://raw.githubusercontent.com/ascarter/dotfiles/master/install)"
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

## Layout

There are two major components to this system. First is to manage what are usually known as `dotfiles` in Git. These are typically in the user's home directory and are preceeded with a `.` to hide them. Examples include `.profile` or `.bashrc`. When it is installed, many of the `.` files are symlinked into a user's home directory allowing for them to be version controlled. A subset of files are managed as templates and instead generate the files. These are useful for more customized files like `.gitconfig`.

The other component is to help manage installing software packages. On macOS, this is mostly handled by Homebrew.
