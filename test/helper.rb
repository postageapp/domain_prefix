require 'rubygems'
require 'test/unit'

require 'turn'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'domain_prefix'

class Test::Unit::TestCase
  def assert_mapping(map)
    result_map = map.inject({ }) do |h, (k,v)|
      h[k] = yield(k)
      h
    end
    
    differences = result_map.inject([ ]) do |a, (k,v)|
      if (v != map[k])
        a << k
      end

      a
    end
    
    assert_equal(map, result_map, differences.collect { |s| "Input: #{s.inspect}\n  Expected: #{map[s].inspect}\n  Result:   #{result_map[s].inspect}\n" }.join(''))
  end
  
  def sample_data(file)
    File.read(
      File.expand_path(
        File.join('sample', file),
        File.dirname(__FILE__)
      )
    )
  end
end
