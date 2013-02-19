# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'kolekt'

Gem::Specification.new do |s|
  s.name        = 'kolekt'
  s.version     = Kolekt::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Pierre Carrier']
  s.email       = ['pierre@gcarrier.fr']
  s.homepage    = 'https://github.com/pcarrier/kolekt'
  s.summary     = 'Collect information about your system'
  s.license     = 'ISC'

  s.add_dependency 'mongodb', '~> 2.1.0'
  s.required_rubygems_version = '>= 1.2.0'

  s.files        = Dir.glob('{bin,lib}/**/*') + %w(COPYING)
  s.executables  = Dir.entries('bin').reject {|e| e.start_with? '.'}
  s.require_path = 'lib'
end
