# Vim Configuration

The vim directory contains a vimrc file and `git submodules` for native vim packages.

## Loading Vimrc

Use the zsh function `vimrc` to generate a `~/.vimrc` that loads the dotfiles vimrc file here. Alternatively, use a symlink:

```
ln -s $DOTFILES/vim/vimrc ~/.vimrc
```

## vimpack

A zsh function `vimpack` is autoloaded that allows the following operations:

```
vimpack [--color] [--plugin] [--opt] add [pack]
vimpack [--color] [--plugin] [--opt] remove [pack]
vimpack update
```

See `vimpack` for complete usage information.

### Manually add Vim package

Use `git submodule add` to add vim packages:

```
git submodule add https://github.com/editorconfig/editorconfig-vim.git vim/pack/plugins/start/editorconfig-vim
git add .gitmodules vim/pack/plugins/start/editorconfig-vim
git commit
```
### Manually update Vim package

Upudate git submodules to update packages:

```
git submodule update --remote --merge
git commit
```

### Manually remove Vim package

Remove the git submodule:

```
git submodule deinit vim/pack/plugins/start/editorconfig-vim
git rm vim/pack/plugins/start/editorconfig-vim
rm -Rf vim/pack/plugins/start/editorconfig-vim
git commit
```
