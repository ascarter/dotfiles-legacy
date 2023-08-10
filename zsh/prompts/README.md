# ZSH Prompts

# Prompt

|Token|Description|
|---|---|
|%n|user|
|%m|host|
|%~|~/path|
|%#|% for user, # for root|

# Colors

zsh colors `%F{<color>}` and `%f`:

|ID|Color|
|---|---|
|0|Black|
|1|Red|
|2|Green|
|3|Yellow|
|4|Blue|
|5|Magenta|
|6|Cyan|
|7|White|
|8|Bright Black|
|9|Bright Red|
|10|Bright Green|
|11|Bright Yellow|
|12|Bright Blue|
|13|Bright Magenta|
|14|Bright Cyan|
|15|Bright White|

# Terminal Title

Update terminal title

```sh
case $(uname) in (Linux) print -Pn "\e]0;%n@%m: %1~\a"; esac
```


# vcs_info

## Prompt

|Token|Description|
|---|---|
|%m|misc|
|%c|staged|
|%u|unstaged|
|%a|action (merge, rebase)|
