require_relative 'helper'

class TestDomainPrefix < Test::Unit::TestCase
  def test_initialization
  end
  
  def test_examples
    assert_mapping(
      'com' => [ nil, nil ],
      'example.com' => %w[ example.com com ],
      'uk.com' => [ nil, nil ],
      'example.net.uk' => %w[ example.net.uk net.uk ],
      'example.uk.com' => %w[ example.uk.com uk.com ],
      'example.ca' =>  %w[ example.ca ca ],
      'example.on.ca' =>  %w[ example.on.ca on.ca ],
      'example.gc.ca' =>  %w[ example.gc.ca gc.ca ],
      'example.co.uk' =>  %w[ example.co.uk co.uk ],
      'example.com.au' => %w[ example.com.au com.au ],
      'example.au' => [ nil, nil ],
      'example.bar.jp' => %w[ bar.jp jp ],
      'example.bar.hokkaido.jp' =>%w[ bar.hokkaido.jp hokkaido.jp ],
      'example.metro.tokyo.jp' => %w[ metro.tokyo.jp tokyo.jp ]
    ) do |domain|
      [
        DomainPrefix.registered_domain(domain),
        DomainPrefix.public_suffix(domain)
      ]
    end
  end
  
  def test_public_suffix_samples
    sample_data('test.txt').split(/\n/).collect do |line|
      line.sub!(/\/\/.*/, '')

      case (line)
      when /checkPublicSuffix\((\S+),\s*(\S+)\)/
        [ $1, $2 ].collect do |part|
          case (part)
          when 'NULL', 'null'
            nil
          else
            part.gsub(/'/, '')
          end
        end
      else
        nil
      end
    end.each do |domain, expected|
      assert_equal expected, DomainPrefix.registered_domain(domain, :relaxed), "#{domain.inspect} -> #{expected.inspect}"
    end
  end
end
