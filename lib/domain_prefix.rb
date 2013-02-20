# encoding: UTF-8

module DomainPrefix
  SEPARATOR = '.'.freeze

  class Tree < Hash
    def insert(path)
      leaf = path.split(SEPARATOR).reverse.inject(self) do |tree, component|
        # Seeds an element into the tree structure by referencing it
        tree[component.sub(/^!/, '')] ||= Tree.new
      end

      if (path.match(/^[\!]/))
        leaf[:required] = 0
      else
        leaf[:required] = 1
      end
      
      self
    end
    
    def follow(path)
      path = path.to_s.split(SEPARATOR) unless (path.is_a?(Array))
      path = path.reverse

      index = traverse(path)

      index and index <= path.length and path[0, index].reverse
    end

  protected
    def traverse(path, index = 0)
      component = path[index]

      unless (component)
        return self[:required] == 0 ? index : nil
      end

      named_branch = self[component]

      if (named_branch)
        result = named_branch.traverse(path, index + 1)

        return result if (result)
      end

      wildcard_branch = self["*"]
      
      if (wildcard_branch)
        result = wildcard_branch.traverse(path, index + 1)

        return result if (result)
      end

      if (!named_branch and !wildcard_branch and self[:required])
        return index + self[:required]
      end

      return
    end
  end
  
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
  
  def rfc3492_canonical_domain(domain)
    # FIX: Full implementation of http://www.ietf.org/rfc/rfc3492.txt required
    domain and domain.downcase
  end

  def public_tld?(tld)
    !NONPUBLIC_TLD.key?(tld)
  end
  
  def registered_domain(domain, rules = :strict)
    return unless (domain)
    
    components = rfc3492_canonical_domain(domain).split(SEPARATOR)
    
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
