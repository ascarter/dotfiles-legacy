# ========================================
# Functions/Completions
# ========================================

fpath=(~/.zsh/functions $fpath)
autoload -U compinit
compinit
autoload -U promptinit
promptinit
autoload -U colors
colors
autoload -U ~/.zsh/functions/[^_]*(:t)
autoload -Uz vcs_info
autoload add-zsh-hook

# ========================================
# Shell preferences
# ========================================

# Editor
if [ -e /usr/local/bin/bbedit ]; then
    # bbedit
    export GIT_EDITOR="bbedit -w"
    export SVN_EDITOR="bbedit -w"
    export EDITOR="bbedit -w"
    export VISUAL="bbedit"
    export LESSEDIT='bbedit -l %lm %f'
    export TEXEDIT='bbedit -w -l %d "%s"'
else
    # vim
    export EDITOR="vim"
    export GIT_EDITOR="${EDITOR}"
    export SVN_EDITOR="${EDITOR}"
    export VISUAL="gvim"
    export LESSEDIT='vim ?lm+%lm. %f'
    export TEXEDIT='vim +%d %s'
fi

# zstyle ':completion:*' verbose yes
# zstyle ':completion:*:descriptions' format '%B%d%b'
# zstyle ':completion:*:messages' format '%d'
# zstyle ':completion:*:warnings' format 'No matches for: %d'
# zstyle ':completion:*' group-name ”

# ========================================
# Terminal settings
# ========================================

# Set directory colors

# Default (light shell)
# export LSCOLORS=exfxcxdxbxegedabagacad

# Dark shell
export LSCOLORS=gxfxcxdxbxegedabagacad

# Key mappings

# Forward delete
bindkey "^[[3~" delete-char

# ========================================
# Prompt
# ========================================

setopt transient_rprompt

# Default
# PS1="%m%# "
declare +x PS1
prompt ascartervcs

if [ "$TERM_PROGRAM" = "Apple_Terminal" ] && [ -z "$INSIDE_EMACS" ]; then
    add-zsh-hook chpwd update_terminal_cwd
    update_terminal_cwd
fi

# Show battery charge on right prompt
# RPS1='$(batterycharge --color --slots 5)'

# _update_pwd() { print -P '%~' }
# add-zsh-hook chpwd _update_pwd

# ========================================
# Aliases
# ========================================
if [ -e ~/.zsh_aliases ]; then
	. ~/.zsh_aliases
fi

# ========================================
# Per-machine extras
# ========================================
if [ -e ~/.zsh_local ]; then
	. ~/.zsh_local
fi
