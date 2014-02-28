# encoding: UTF-8
require 'simpleidn'

module DomainPrefix
  require 'domain_prefix/tree'

  SEPARATOR = '.'.freeze

  TLDIFIER_SOURCE_FILE = File.expand_path(File.join('..', 'data', 'effective_tld_names.dat'), File.dirname(__FILE__))

  TLD_SET = begin
    File.open(TLDIFIER_SOURCE_FILE, 'r:UTF-8') do |f|
      f.read.split(/\n/).collect do |line|
        line.sub(%r[//.*], '').sub(/\s+$/, '')
      end.reject(&:empty?).freeze
    end
  end
  
  TLD_NAMES = TLD_SET.sort_by do |d|
    [ -d.length, d ]
  end.freeze
  
  TLD_TREE = TLD_NAMES.inject(Tree.new) do |t, name|
    t.insert(name)
  end.freeze
  
  NONPUBLIC_TLD = {
    'local' => true
  }.freeze
  
  # Returns a cleaned up, canonical version of a domain name.
  def rfc3492_canonical_domain(domain)
    # FIX: Full implementation of RFC3429 required.
    # http://www.ietf.org/rfc/rfc3492.txt
    domain and domain.downcase
  end

  # Returns true if the given tld is listed as public, false otherwise.
  def public_tld?(tld)
    !NONPUBLIC_TLD.key?(tld)
  end
  
  # Returns the registered domain name for a given FQDN or nil if one cannot
  # be determined.
  def registered_domain(fqdn, rules = :strict)
    return unless (fqdn)
    
    components = rfc3492_canonical_domain(fqdn).split(SEPARATOR)
    
    return if (components.empty? or components.find(&:empty?))

    if (rules == :strict)
      return unless (self.public_tld?(components.last))
    end

    suffix = TLD_TREE.follow(components)

    unless (suffix)
      if (rules == :relaxed and components.length >= 2 and !TLD_TREE[components[-1]])
        return components.last(2).join(SEPARATOR)
      else
        return
      end
    end
    
    suffix.join(SEPARATOR)
  end

  # Returns the public suffix (e.g. "co.uk") for a given domain or nil if one
  # cannot be determined.
  def public_suffix(domain)
    return unless (domain)

    components = rfc3492_canonical_domain(domain).split(SEPARATOR)

    return if (components.empty? or components.find(&:empty?))

    return unless (public_tld?(components.last))

    suffix = TLD_TREE.follow(components)
    
    return unless (suffix)

    suffix.shift

    suffix.join(SEPARATOR)
  end

  # Returns the very top-level domain for a given domain, or nil if one cannot
  # be determined.
  def tld(fqdn)
    suffix = public_suffix(rfc3492_canonical_domain(fqdn))
    
    suffix and suffix.split(SEPARATOR).last
  end

  # Returns the name component of a given domain or nil if one cannot be
  # determined.  
  def name(fqdn)
    if (fqdn = registered_domain(fqdn))
      fqdn.split(SEPARATOR).first
    else
      nil
    end
  end
  
  extend self
end
