#!/bin/bash -e

puppet_file="/builder/Puppetfile"
puppet_modules="/builder/output"
cache_dir="/builder/cache"

source /opt/rh/rh-ruby*/enable

# fetch required puppet modules
r10k puppetfile install --verbose info --moduledir "${puppet_modules}" --puppetfile "${puppet_file}"

# remove .git directories
find "${puppet_modules}" -name ".git" -prune -exec rm -rf {} \;

chown --reference="${puppet_file}" -R "${puppet_modules}"/
chown --reference="${puppet_file}" -R "${cache_dir}"/
