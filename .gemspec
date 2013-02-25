# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'syster'

Gem::Specification.new do |s|
  s.name        = 'syster'
  s.version     = Syster::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Pierre Carrier']
  s.email       = ['pierre@gcarrier.fr']
  s.homepage    = 'https://github.com/pcarrier/syster'
  s.summary     = 'Collect information about your system'
  s.license     = 'ISC'

  s.required_rubygems_version = '>= 1.2.0'

  s.files        = Dir.glob('{bin,lib}/**/*') + %w(COPYING)
  s.executables  = Dir.entries('bin').reject {|e| e.start_with? '.'}
  s.require_path = 'lib'
end
