#  -*- mode: unix-shell-script; -*-

dockerrmi() {
	if [[ -z "$1" ]]; then
		local images=$(docker images --quiet --filter "dangling=true")
	else
		local images=$(docker images --quiet $1)
	fi

	if [[ -n "${images}" ]]; then
		docker rmi ${images}
	fi
}

# Remove all images including intermediate
dockercleanup() {
	if [[ -z "$1" ]]; then
		local images=$(docker images --quiet --all --filter "dangling=true")
	else
		local images=$(docker images --quiet --all $1)
	fi

	if [[ -n "${images}" ]]; then
		docker rmi --force ${images}
	fi
}
