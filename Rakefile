require 'rubygems'
require 'rake'

require 'bundler/setup'
require 'open-uri'

begin
  require 'juwelier'

  Juwelier::Tasks.new do |gem|
    gem.name = 'domain_prefix'
    gem.summary = 'Domain Prefix Extraction Library'
    gem.description = 'A library to extract information about top-level domain and registered name from generic and international domain names'
    gem.email = 'tadman@postageapp.com'
    gem.homepage = 'http://github.com/postageapp/domain_prefix'
    gem.authors = [ 'Scott Tadman' ]
  end

  Juwelier::GemcutterTasks.new
rescue LoadError
  puts 'Juwelier (or a dependency) not available. Install it with: gem install Juwelier'
end

require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

namespace :domain_prefix do
  desc 'Update the domain information'
  task :update do
    URI.open('https://publicsuffix.org/list/public_suffix_list.dat') do |source|
      open(File.expand_path(File.join('data', 'effective_tld_names.dat'), File.dirname(__FILE__)), 'w') do |dest|
        dest.write(source.read)
      end
    end

    URI.open('https://raw.githubusercontent.com/publicsuffix/list/master/tests/test_psl.txt') do |source|
      open(File.expand_path(File.join('test', 'sample', 'test.txt'), File.dirname(__FILE__)), 'w') do |dest|
        dest.write(source.read)
      end
    end
  end
end

task default: :test
