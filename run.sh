#!/bin/bash -e

#
# author: Arkadiusz Dzięgiel <arkadiusz.dziegiel@glorpen.pl>
#

TEMP=$(getopt -o c:i: --long cache: --long image: -n 'puppetfile-resolver' -- "$@")

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "$TEMP"

while true;
do
	case "$1"
	in
		-c|--cache)
			cache_path="$(realpath "${2}")"; shift 2;;
		-i|--image)
			image_name="${2}"; shift 2;;
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

echo "Running container..."

DOCKER_ARGS="--env HTTPS_PROXY=http://172.17.0.2:3128 --env HTTP_PROXY=http://172.17.0.2:3128 --env http_proxy=http://172.17.0.2:3128"

if [ "$cache_path" != "" ];
then
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
"${image_name:-glorpen/puppetfile-resolver}" $@
