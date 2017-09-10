#!/bin/bash -e

TEMP=$(getopt -o c: --long cache: -n 'puppetfile-resolver' -- "$@")


if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "$TEMP"

while true;
do
	case "$1"
	in
		-c|--cache)
			cache_path="$(realpath "${2}")"; shift 2;;
		--)
			shift; break;;
		*) echo "Internal error!" ; exit 1 ;;
	esac
done

puppetfile_path="$(realpath ${1})"; shift;
output_dir="$(realpath ${1})"; shift;

echo "Puppetfile: $puppetfile_path"
echo "Output: $output_dir"
echo "Cache path: ${cache_path:-[not set]}"

echo ""

DOCKER_ARGS=""

if [ "$cache_path" != "" ];
then
	 if [ ! -w "${cache_path}" ] || [ ! -d "${cache_path}" ];
	 then
	 	echo "Cache dir is not a writtable directory"
	 	exit 1
	 fi
	 DOCKER_ARGS="${DOCKER_ARGS} -v ${cache_path}:/builder/cache"
fi

if [ ! -r "${puppetfile_path}" ] || [ ! -f "${puppetfile_path}" ];
then
	echo "Puppetfile is not readable"
fi

tmp_path="/dev/shm/puppet-builder"
mkdir -p "${tmp_path}"
trap "{ rm -rf '${tmp_path}'; }" EXIT

docker run --rm \
-v "${puppetfile_path}":/builder/Puppetfile:ro \
-v "${output_dir}":/builder/output \
-v "${HOME}/.ssh":"/builder/.ssh":ro \
-v "${tmp_path}":/tmp \
$DOCKER_ARGS \
glorpen/puppetfile-resolver $@
