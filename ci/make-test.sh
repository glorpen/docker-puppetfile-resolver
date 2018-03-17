#
# author: Arkadiusz Dzięgiel <arkadiusz.dziegiel@glorpen.pl>
#

OUTPUT_PATH=/tmp/output
PUPPETFILE=/tmp/Puppetfile
CACHE_PATH=/tmp/cache
FAIL_LOCK=/tmp/.unit-fail

function run(){
	echo -e "${1}" > /tmp/Puppetfile
	touch -t 190001010000 /tmp/Puppetfile
	mkdir -p "${OUTPUT_PATH}"
	touch -t 190001010001 "${OUTPUT_PATH}"
	bash run.sh "${PUPPETFILE}" "${OUTPUT_PATH}" --cache "${CACHE_PATH}" --image "${REPO_NAME}":"${REPO_TAG}"
}

function clean(){
	rm -rf "${OUTPUT_PATH}" "${CACHE_PATH}" "${FAIL_LOCK}"
}

function _fail(){
	touch "${FAIL_LOCK}"
}

function _exit2str(){
	if [ ${1} -eq 0 ];
	then
		echo -n "ok"
	else
		echo -n "failed"
	fi
}

function check_exists(){
	test -e "${1}"
	ret=$?
	[ $ret -ne 0 ] && _fail
	echo "## ${2:-Checking ${1}}.. $(_exit2str $ret)"
}
function check_exists_not(){
	test ! -e "${1}"
	ret=$?
	[ $ret -ne 0 ] && _fail
	echo "## ${2:-Inverse checking ${1}}.. $(_exit2str $ret)"
}

function check_cache(){
	check_exists "${CACHE_PATH}/${1}" "${2}"
}
function check_output(){
	check_exists "${OUTPUT_PATH}/${1}" "${2}"
}
function check_output_not(){
	check_exists_not "${OUTPUT_PATH}/${1}" "${2}"
}

run "mod 'puppetlabs/stdlib', '4.20.0'"
check_cache "puppetlabs-stdlib-4.20.0" "forge stdlib-4.20 module should be cached"
check_output "stdlib" "forge stdlib module should be installed"

run "mod 'puppetlabs/stdlib', '4.19.0'\nmod 'puppetlabs/concat', git: 'https://github.com/puppetlabs/puppetlabs-concat.git'"
check_cache "puppetlabs-stdlib-4.19.0" "forge stdlib-4.19 module should be cached"
check_cache "puppetlabs-stdlib-4.20.0" "forge stdlib-4.20 module should be cached"
check_cache "https---github.com-puppetlabs-puppetlabs-concat.git" "git concat module should be cached"
check_output "stdlib" "stdlib module should be installed"
check_output "concat" "git concat module should be installed"

run "mod 'puppetlabs/stdlib', '4.19.0'"
check_output_not "concat" "git concat module should not be installed"

if [ -e "${FAIL_LOCK}" ];
then
	echo "!! Some tests failed"
	exit 1
else
	echo "-- All tests passed"
	clean
fi
