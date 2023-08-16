# Open man page as pdf

emulate -L zsh

case $(uname) in
Darwin )
  local page
  for page in "${(@f)"$(man -w $@)"}"; do
    command mandoc -Tpdf $page | open -f -a Preview
  done
  ;;
Linux )
  # TODO: Add Linux support
  ;;
esac
