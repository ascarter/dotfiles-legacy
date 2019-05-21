#  -*- mode: unix-shell-script; -*-

# Run command in container with local directory mounted
# Useful for scripting languages like Ruby, Python, and Node
# Usage: docker_cmd <image> <bin> <cmd> [args]
docker_cmd() {
	local image=$1; shift
	local bin=$1; shift
	local cmd=$1; shift
	local args=$*
	docker run -it --rm -v "$PWD":/usr/src/app -w /usr/src/app ${image} ${bin} ${cmd} ${args}
}

# Override DOCKER_RUBY_VERSION for specific Ruby version (default to latest)
DOCKER_RUBY_VERSION=${DOCKER_RUBY_VERSION:-latest}

# Run script using Ruby version in docker
# Usage: docker_ruby <bin> <cmd> [args]
docker_ruby() {
	docker_cmd ruby:${DOCKER_RUBY_VERSION} $*
}

druby() {
	docker_ruby ruby $*
}

dgem() {
	docker_ruby gem $*
}

dbundle() {
	docker_ruby bundle $*
}

# Override DOCKER_NODE_VERSION for specific Node version (default to latest)
DOCKER_NODE_VERSION=${DOCKER_RUBY_VERSION:-latest}

# Run script using node version in docker
# Usage: docker_node <bin> <cmd> [args]
docker_node() {
	docker_cmd node:${DOCKER_NODE_VERSION} $*
}

dnode() {
	docker_node node $*
}

dnpm() {
	docker_node npm $*
}


#  -*- mode: unix-shell-script; -*-

# Override DOCKER_PYTHON_VERSION for specific Python version (default to latest)
DOCKER_PYTHON_VERSION=${DOCKER_PYTHON_VERSION:-latest}

# Run script using Python version in docker
# Usage: docker_python <bin> <cmd> [args]
docker_python() {
	docker_cmd python:${DOCKER_PYTHON_VERSION} $*
}

dpy() {
	docker_python python $*
}

dpip() {
	docker_python pip $*
}

# Override DOCKER_GO_VERSION for specific Go version (default to latest)
DOCKER_GO_VERSION=${DOCKER_GO_VERSION:-latest}

# Run script using Go version in docker
# Usage: docker_go <bin> <cmd> [args]
docker_go() {
	docker_cmd golang:${DOCKER_GO_VERSION} $*
}

dgo() {
	docker_go go $*
}

dgomake() {
	docker_go make $*
}

# Remove all matching images
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
