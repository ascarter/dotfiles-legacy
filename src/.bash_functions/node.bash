#  -*- mode: unix-shell-script; -*-

# Run script using node version in docker
# Usage: docker_node <script> <node_version>
docker_node() {
	local version=$1; shift
	local script=$1; shift
	local args=$*
	docker run -it --rm -v "$PWD":/home/node/app -w /home/node/app node:${version} node ${script} ${args}
}

dnode8() {
	docker_node 8 $*
}

dnode10() {
	docker_node 10 $*
}

dnode11() {
	docker_node 11 $*
}

dnode() {
	docker_node latest $*
}

docker_npm() {
	local version=$1; shift
	local cmd=$1; shift
	local args=$*

	docker run -it --rm -v "$PWD":/home/node/app -w /home/node/app node:${version} npm ${cmd} ${args}
}

dnpm8() {
	docker_npm 8 $*
}

dnpm10() {
	docker_npm 10 $*
}

dnpm11() {
	docker_npm 11 $*
}

dnpm() {
	docker_npm latest $*
}
