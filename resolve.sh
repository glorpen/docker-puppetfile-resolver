#!/bin/sh -e

PUPPET_FILE="/builder/Puppetfile"
PUPPET_MODULES_PATH="/builder/output"
CACHE_PATH="/builder/cache"

TARGET_UID=$(stat -c %u "${PUPPET_FILE}")
TARGET_GID=$(stat -c %g "${PUPPET_FILE}")

do_resolve(){	
	echo "Puppetfile changed, updating modules"
	
	# fetch required puppet modules
	r10k puppetfile install --verbose info --moduledir "${PUPPET_MODULES_PATH}" --puppetfile "${PUPPET_FILE}"
	
	# remove .git directories
	find "${PUPPET_MODULES_PATH}" -name ".git" -prune -exec rm -rf {} \;
	# remove spec directories
	find "${PUPPET_MODULES_PATH}" -maxdepth 2 -mindepth 2 -name "spec" -type d -prune -exec rm -rf {} \;
	
	touch -m -r "${PUPPET_FILE}" "${PUPPET_MODULES_PATH}"
}

do_check(){
	if [ ! "${PUPPET_FILE}" -nt "${PUPPET_MODULES_PATH}" ] && [ ! "${PUPPET_FILE}" -ot "${PUPPET_MODULES_PATH}" ];
	then
		echo "Puppetfile did not change, exitting."
		exit 0
	fi
}
add_user(){
	groupadd -og $TARGET_GID builder
	MAIL_DIR=/tmp useradd -s /bin/sh -d /builder -NMo -u $TARGET_UID -g $TARGET_GID builder
}

if [ $(id -u) -eq 0 ];
then
	do_check
	add_user
	
	mkdir -p "${CACHE_PATH}" "${PUPPET_MODULES_PATH}"
	chown $TARGET_UID:$TARGET_GID -R "${PUPPET_MODULES_PATH}"/ "${CACHE_PATH}"/
	
	echo "Dropping privileges"
	su builder -c /usr/local/bin/puppetfile-resolve
else
	do_resolve
fi
