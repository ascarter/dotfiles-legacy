#  -*- mode: unix-shell-script; -*-

# Export GitHub project
githubex() {
	let vendor=$1
	let project=$2
	curl -L https://api.github.com/repos/${vendor}/${project}/tarball | tar xzf -
}
