# encoding: UTF-8

module DomainPrefix
  class TreeHash < Hash
    def initialize
      super do |h, k|
        h[k] = TreeHash.new
      end
    end
    
    def find_domain(domain)
      domain.split('.').inject(self) do |h, component|
        h and h.key?(component) ? h[component] : nil
      end
    end
  end
  
  TLDIFIER_SOURCE_FILE = File.expand_path(File.join('..', 'data', 'effective_tld_names.dat'), File.dirname(__FILE__))

  TLD_SET = File.read(TLDIFIER_SOURCE_FILE).split(/\n/).collect do |line|
    line.sub(%r[//.*], '').sub(/\s+$/, '')
  end.reject(&:empty?).freeze
  
  TLD_NAMES = TLD_SET.sort_by do |d|
    [ -d.length, d ]
  end.freeze
  
  TLD_TREE = TLD_NAMES.inject(TreeHash.new) do |h, name|
    name.split('.').reverse.inject(h) do |_h, component|
      case (component)
      when '*'
        _h
      when /!(.*)/
        _h[$1]
      else
        _h[component]
      end
    end

    h
  end.freeze

  PREFIX_SPEC = Regexp.new(
    '^(' + TLD_NAMES.collect do |d|
      Regexp.escape(d).sub(/^\\\*\\\./, '')
    end.join('|') + ')$'
  ).freeze
  
  ALLOWED_DOMAIN_PREFIXES = Hash[
    TLD_NAMES.select do |d|
      d.match(/^\!/)
    end.collect do |d|
      [ d.sub(/^\!/, ''), true ]
    end
  ].freeze

  DOMAIN_PREFIX_SPEC = Regexp.new(
    '^(?:[^\.]+\.)*?(([^\.]+)\.(' + TLD_NAMES.collect do |d|
      Regexp.escape(d).sub(/^\\\*\\\./, '[^\.]+\.')
    end.join('|') + '))$'
  ).freeze
  
  NONPUBLIC_TLD = {
    'local' => true
  }.freeze
  
  def rfc3492_canonical_domain(domain)
    # FIX: Full implementation of http://www.ietf.org/rfc/rfc3492.txt required
    domain and domain.downcase
  end

  def registered_domain(domain)
    m = DOMAIN_PREFIX_SPEC.match(rfc3492_canonical_domain(domain))
    
    return unless (m)

    domain = m[1]
    suffix = m[3]
    
    return if (NONPUBLIC_TLD[suffix])
    return if (PREFIX_SPEC.match(domain) and !ALLOWED_DOMAIN_PREFIXES[domain])
    
    domain
  end

  def public_suffix(domain)
    m = DOMAIN_PREFIX_SPEC.match(rfc3492_canonical_domain(domain))
    
    return unless (m)
    
    domain = m[1]
    suffix = m[3]
    
    return if (PREFIX_SPEC.match(domain) and !ALLOWED_DOMAIN_PREFIXES[domain])
    
    suffix
  end

  def tld(domain)
    suffix = public_suffix(rfc3492_canonical_domain(domain))
    
    suffix and suffix.split(/\./).last
  end
  
  def name(domain)
    m = DOMAIN_PREFIX_SPEC.match(rfc3492_canonical_domain(domain))
    
    m and m[2]
  end
  
  extend self
end
