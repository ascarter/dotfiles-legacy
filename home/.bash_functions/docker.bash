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

# Run app via docker
dk() {
	# Usage: dk <cmd> <app> [args]
	local cmd=$1; shift
	local app=$1; shift
	local args=$*
	
	local name_prefix="${USER}_"
	local name="${name_prefix}${app}"
	local drun="docker run --rm --name=${name}"
	
	# Set docker run arguments
	case "${app}" in
		memcached)
			drun+=" -d -p 11211:11211 memcached"
			;;
		redis)
			drun+=" -d -p 6379:6379 redis"
			;;
		redis-cli)
			drun+=" -it --link ${name_prefix}redis:redis redis redis-cli -h redis -p 6379"
			;;
		postgres)
			drun+=" -d -p 5432:5432 -e POSTGRES_PASSWORD=password postgres"
			;;
		psql)
			drun+=" -it --link ${name_prefix}postgres:postgres postgres psql -h postgres -U postgres -W"
			;;
		node)
			drun+=" -it -v ${PWD}:/usr/src/app -w /usr/src/app node node"
			;;
		*)
			if [ -z "${cmd}" ] || [ "${cmd}" != "ps" ]; then
				echo "Usage: dk <cmd> <app> [args]"
				echo ""
				echo "Commands:"
				echo "    start -- start app"
				echo "    stop  -- stop app"
				echo "    bash  -- start bash shell in app container"
				echo "    ps    -- show process status"
				echo ""
				echo "Apps:"
				echo "    memcached"
				echo "    redis"
				echo "    redis-cli"
				echo "    postgres"
				echo "    psql"
				echo "    node"
				return 1
			fi
			;;
	esac

	# Handle command
	case ${cmd} in
		start)
			${drun} ${args}
			;;
		stop)
			docker stop $(docker ps -f name=${name} -q)
			;;
		shell)
			docker exec -it $(docker ps -f name=${name} -q) bash
			;;
		ps)
			docker ps -f name=${name}
			;;
	esac
}
