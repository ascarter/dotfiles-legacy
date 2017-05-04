#!/bin/bash
# Bash completion support for Rake

_rakecomplete() {
    local cur
    _get_comp_words_by_ref -n : cur
    rakefile=`find . -maxdepth 1 -iname Rakefile`
    if [ -e "$rakefile" ]; then
		local tasks=$(rake --silent --tasks | cut -d " " -f 2)
		COMPREPLY=($(compgen -W "${tasks}" -- "${cur}"))
		__ltrim_colon_completions "${cur}"
    fi
}

complete -o default -o nospace -F _rakecomplete rake
