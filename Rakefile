require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "domain_prefix"
    gem.summary = "Domain Prefix Extraction Library"
    gem.description = "A library to extract information about top-level domain and registered name from generic and international domain names"
    gem.email = "github@tadman.ca"
    gem.homepage = "http://github.com/twg/domain_prefix"
    gem.authors = %w[ tadman ]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

namespace :domain_prefix do
  desc "Update the domain information"
  task :update do
    require 'open-uri'
    
    open("http://mxr.mozilla.org/mozilla-central/source/netwerk/dns/effective_tld_names.dat?raw=1") do |source|
      open(File.expand_path(File.join('data', 'effective_tld_names.dat'), File.dirname(__FILE__)), 'w') do |dest|
        dest.write(source.read)
      end
    end
  end
end
