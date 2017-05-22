#  -*- mode: unix-shell-script; -*-

# Shortcuts
alias projects='cd ${PROJECTS_HOME}'
alias src='cd ${PROJECTS_HOME}/src'
alias mysrc='cd ${PROJECTS_HOME}/src/github.com/${GITHUB_USER}'

# Switch to a project
scd() { cd ${PROJECTS_HOME}/src/${1} ; }

# Switch to github project
gcd() { cd ${PROJECTS_HOME}/src/github.com/${1} ; }

# Clone GitHub project
# Argument should be like `owner/project`
gclone() {
	local github_path=${PROJECTS_HOME}/src/github.com
	mkdir -p ${github_path}
	hub clone ${1} ${github_path}/${1}
	gcd ${1}
}

# Find go workspace for the current directory
gows() {
    local wspath=$(pwd)
    while [[ "$wspath" != "" ]] && ! [[ -d "$wspath/bin" && -d "$wspath/pkg" && -d "$wspath/src" ]]; do
        wspath=${wspath%/*}
    done

    if [[ -z ${wspath} ]]; then
		printf "Go workspace not found"
		return 1
	fi

	printf "$wspath"
}

# Search up path until target directory is found
upsearch() {
	local P=$(pwd)
	while [[ "$P" != "" && ! -e "$P/$1" ]]; do
		P=${P%/*}
	done
	print "$P"
}

