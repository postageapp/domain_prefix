# domain_prefix

This is a library to determine the registration prefix for a given domain
and can be used to assert if a given domain name is valid or not.

## Update Task

To update the data used to make the domain determinations, there's a
rake task:

    rake domain_prefix:update

The test case data is pulled from a separate source:

    http://mxr.mozilla.org/mozilla-central/source/netwerk/test/unit/data/test_psl.txt?raw=1

## Copyright

Copyright (c) 2009-2014 Scott Tadman, The Working Group Inc.
See LICENSE for details.
