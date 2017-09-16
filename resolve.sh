#!/bin/bash -e

puppet_file="/builder/Puppetfile"
puppet_modules="/builder/output"
cache_dir="/builder/cache"

if [ ! "${puppet_file}" -nt "${puppet_modules}" ];
then
	echo "Puppetfile did not change, exitting."
	exit 0
fi

source /opt/rh/rh-ruby*/enable

echo "Puppetfile changed, Updating modules"

# fetch required puppet modules
r10k puppetfile install --verbose info --moduledir "${puppet_modules}" --puppetfile "${puppet_file}"

# remove .git directories
find "${puppet_modules}" -name ".git" -prune -exec rm -rf {} \;
# remove spec directories
find "${puppet_modules}" -maxdepth 2 -mindepth 2 -name "spec" -type d -prune -exec rm -rf {} \;

chown --reference="${puppet_file}" -R "${puppet_modules}"/
chown --reference="${puppet_file}" -R "${cache_dir}"/

touch -m -r "${puppet_file}" "${puppet_modules}"
