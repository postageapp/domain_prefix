# domain_prefix

This is a library to determine the registration prefix for a given domain
and can be used to assert if a given domain name is valid or not.

## Usage

The `registered_domain` method returns the name of the registered domain
associated witha given hostname, or Fully Qualified Domain Name (FQDN):

   DomainPrefix.registered_domain('test.example.com')
   # => 'example.com'
   DomainPrefix.registered_domain('test.example.ca')
   # => 'example.ca'
   DomainPrefix.registered_domain('test.example.co.uk')
   # => 'example.co.uk'

The `public_suffix` method returns the suffix into which this domain is
registered:

   DomainPrefix.public_suffix('test.example.com')
   # => 'com'
   DomainPrefix.public_suffix('test.example.ca')
   # => 'ca'
   DomainPrefix.public_suffix('test.example.co.uk')
   # => 'co.uk'

Note that the "public suffix" component of a domain can be quite lengthy
depending on the context. Some countries have three or more levels of structure
in their TLD.

In some cases there are quasi-TLD listings in this file relating to common
hosting platforms like `xs4all.space` or dynamic DNS providers like DynDNS
with suffixes like `dnsalias.com`.

As no distinction is made in the source `.dat` file between these hosting
companies and TLD registry structures it's not possible to differentiate
in this library either.

## Update Task

To update the data used to make the domain determinations, there's a
rake task:

    rake domain_prefix:update

The test case data is pulled from a separate source:

    http://mxr.mozilla.org/mozilla-central/source/netwerk/test/unit/data/test_psl.txt?raw=1

The source of this data is the [Public Suffix List](https://github.com/publicsuffix/list)
which is licensed under the Mozilla Public License 2.0. A portion of this
project is included in this gem.

## Copyright

Copyright (c) 2009-2017 Scott Tadman, The Working Group Inc.
See LICENSE for details.
