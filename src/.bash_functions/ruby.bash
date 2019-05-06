#  -*- mode: unix-shell-script; -*-

# Run script using Ruby version in docker
# Usage: docker_ruby <ruby_version> <script>
docker_ruby() {
	local version=$1; shift
	local script=$1; shift
	local args=$*
	docker run -it --rm -v "$PWD":/usr/src/app -w /usr/src/app ruby:${version} ruby ${script} ${args}
}

drb26() {
	docker_ruby 2.6 $*
}

drb25() {
	docker_ruby 2.5 $*
}

drb2() {
	docker_ruby 2 $*
}

drb() {
	docker_ruby latest $*
}

docker_gem() {
	local version=$1; shift
	local cmd=$1; shift
	local args=$*

	docker run -it --rm -v "$PWD":/usr/src/app -w /usr/src/app gem ${cmd} ${args}
}

dgem26() {
	docker_gem 2.6 $*
}

dgem25() {
	docker_gem 2.5 $*
}

dgem2() {
	docker_gem 2 $*
}

dgem() {
	docker_gem latest $*
}
