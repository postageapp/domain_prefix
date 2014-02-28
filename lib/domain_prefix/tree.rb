class DomainPrefix::Tree < Hash
  def insert(path)
    components = path.sub(/^!/, '').split(DomainPrefix::SEPARATOR).reverse

    leaves = components.inject([ self ]) do |trees, part|
      [ part, SimpleIDN.to_unicode(part), SimpleIDN.to_ascii(part) ].uniq.flat_map do |l|
        trees.collect do |tree|
          tree[l] ||= self.class.new
        end
      end
    end

    required = path.match(/^[\!]/) ? 0 : 1

    leaves.each do |leaf|
      leaf[:required] = required
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
