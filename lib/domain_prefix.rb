# encoding: UTF-8

module DomainPrefix
  SEPARATOR = '.'.freeze

  class Tree < Hash
    def initialize
      super do |h, k|
        h[k] = Tree.new
      end
    end
    
    def insert(path)
      path.split(SEPARATOR).reverse.inject(self) do |tree, component|
        tree[component]
      end
      
      self
    end
    
    def follow(path)
      path = path.to_s.split(SEPARATOR) unless (path.is_a?(Array))
      prefix = [ ]
      tree = self
      
      path.reverse.each do |component|
        if (!component or component.empty?)
          return
        end

        if (tree.key?(component))
          # This component is REQUIRED and IS considered part of the actual
          # prefix.
          prefix.unshift(component)

          # Further testing is necessary to determine if a more specific
          # match can be made.
          tree = tree[component]
        elsif (tree.key?("!#{component}"))
          # This component is REQUIRED but IS NOT considered part of the
          # actual prefix.
          return prefix
        elsif (tree.key?("*"))
          # This component is REQUIRED and IS considered part of the actual
          # prefix.
          prefix.unshift(component)
          
          # No further testing is required as wildcards in the middle of
          # TLDs are not supported.
          
          return prefix
        else
          # If no specific match can be found, then testing is done.
          return prefix.empty? ? nil : prefix
        end
      end
      
      # Getting here means the matching process failed because path was not
      # sufficiently long.
      return
    end
  end
  
  TLDIFIER_SOURCE_FILE = File.expand_path(File.join('..', 'data', 'effective_tld_names.dat'), File.dirname(__FILE__))

  TLD_SET = File.read(TLDIFIER_SOURCE_FILE).split(/\n/).collect do |line|
    line.sub(%r[//.*], '').sub(/\s+$/, '')
  end.reject(&:empty?).freeze
  
  TLD_NAMES = TLD_SET.sort_by do |d|
    [ -d.length, d ]
  end.freeze
  
  TLD_TREE = TLD_NAMES.inject(Tree.new) do |t, name|
    t.insert(name)
  end.freeze
  
  NONPUBLIC_TLD = {
    'local' => true
  }.freeze
  
  def rfc3492_canonical_domain(domain)
    # FIX: Full implementation of http://www.ietf.org/rfc/rfc3492.txt required
    domain and domain.downcase
  end

  def public_tld?(tld)
    !NONPUBLIC_TLD.key?(tld)
  end
  
  def registered_domain(domain)
    return unless (domain)
    
    components = rfc3492_canonical_domain(domain).split(SEPARATOR)
    
    return if (components.empty? or components.find(&:empty?))

    return unless (public_tld?(components.last))

    prefix = TLD_TREE.follow(components)
    
    return unless (prefix)
    
    offset = prefix.length + 1

    if (offset > components.length)
      return
    end

    components[-offset, offset].join(SEPARATOR)
  end

  def public_suffix(domain)
    return unless (domain)

    components = rfc3492_canonical_domain(domain).split(SEPARATOR)

    return if (components.empty? or components.find(&:empty?))

    return unless (public_tld?(components.last))

    prefix = TLD_TREE.follow(components)
    
    return unless (prefix)
    
    offset = prefix.length

    if (offset >= components.length)
      return
    end

    components[-offset, offset].join(SEPARATOR)
  end

  def tld(domain)
    suffix = public_suffix(rfc3492_canonical_domain(domain))
    
    suffix and suffix.split(SEPARATOR).last
  end
  
  def name(domain)
    if (domain = registered_domain(domain))
      domain.split(SEPARATOR).first
    else
      nil
    end
  end
  
  extend self
end
