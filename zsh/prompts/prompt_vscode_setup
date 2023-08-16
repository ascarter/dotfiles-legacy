# code zsh prompt theme
# Andrew Carter <ascarter@uw.edu>
#
# VS Code prompt with minimal vcs info
#

prompt_vscode_help () {
  cat <<'EOH'
VS Code prompt with minimal vcs info

By default, this script provides a custom command prompt that includes information
about the git repository for the current folder. However, with certain large repositories,
this can result in a slow command prompt due to the performance of needed git operations.

For performance reasons, a "dirty" indicator that tells you whether or not there are
uncommitted changes is disabled by default. You can opt to turn this on for smaller repositories
by entering the following in a terminal or adding it to your postCreateCommand:

```
git config devcontainers-theme.show-dirty 1
```

To completely disable the git portion of the prompt for the current folder's repository,
you can use this configuration setting instead:

```
git config devcontainers-theme.hide-status 1
```
EOH
}

prompt_vscode_setup () {
  if [[ "$TERM" = "xterm-256color" ]]; then
    SEPARATOR="➜"
    GIT_DIRTY="✗"
  else
    SEPARATOR="|"
    GIT_DIRTY="x"
  fi

  # Check if vcs_info is available
  if [[ $(whence -w 'vcs_info' | cut -d ':' -f 2 | xargs) == function ]]; then
    # Prompt: user@host ~/path vcs_info %
    PROMPT='%F{2}%B%n@%m%b%f ${SEPARATOR} %F{4}%B%~%b%f${vcs_info_msg_0_} %# '
    PROMPT4='+%N:%i:%_>'
    prompt_opts=( cr percent subst sp )

    # Use misc field to set dirty status and supress staged/unstaged
    +vi-dirty() {
      if [[ ! $(git config --bool devcontainers-theme.hide-status) == "true" && $(git config --bool devcontainers-theme.show-dirty) == "true" ]]  && \
              git --no-optional-locks ls-files --error-unmatch -m --directory --no-empty-directory -o --exclude-standard ":/*" > /dev/null 2>&1; then
          hook_com[misc]=" ${GIT_DIRTY}"
      else
          hook_com[misc]=""
      fi
    }

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:git:*' check-for-changes false
    zstyle ':vcs_info:git:*' formats " %F{6}(%f%F{1}%b%f%F{3}%m%f%F{6})%f"
    zstyle ':vcs_info:git:*' actionformats " %F{6}(%f%F{1}%b%f %F{3}%m%f%F{6}|%F{9}%B%a%b%f)%f"
    zstyle ':vcs_info:git*+set-message:*' hooks dirty

    terminal_title() {
      # Update terminal title
      case $(uname) in (Linux) print -Pn "\e]0;%n@%m: %1~\a"; esac
    }

    precmd() {
      vcs_info
      terminal_title
    }
  fi
}

prompt_vscode_setup "$@"
