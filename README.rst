===================
Puppetfile Resolver
===================

This container will simply checkout modules in given ``Puppetfile`` to path binded to ``/builder/output``.

All resulting file will be owned by the owner of provided ``Puppetfile``.

Usage
=====

With helper script:

.. sourcecode:: bash

   ./run.sh Puppetfile ./output --cache ./cache 

Bare docker:

.. sourcecode:: bash

   docker run --rm \
   -v "${puppetfile_path}":/builder/Puppetfile:ro \
   -v "${output_dir}":/builder/output \
   glorpen/puppetfile-resolver


Speed
=====

When installing modules, r10k frequently stores and accesses files in ``/tmp``.
Doing it on directory overlayed by Docker is somehow slow so to speed it up you can bind ``/tmp`` to host, eg.:

.. sourcecode:: bash

   docker run --rm \
   -v "${puppetfile_path}":/builder/Puppetfile:ro \
   -v "${output_dir}":/builder/output \
   -v "${tmp_path}":/tmp \
   glorpen/puppetfile-resolver

Caching
=======

To cache modules downloaded from forge and git, store ``/builder/cache`` by eg. binding to host dir, eg.:

.. sourcecode:: bash

   docker run --rm \
   -v "${puppetfile_path}":/builder/Puppetfile:ro \
   -v "${output_dir}":/builder/output \
   -v "${cache_dir}":/builder/cache \
   glorpen/puppetfile-resolver

