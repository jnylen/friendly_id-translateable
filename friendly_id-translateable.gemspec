# encoding: utf-8
require File.expand_path('../lib/friendly_id/translateable/version', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'friendly_id-translateable'
  s.version       = FriendlyId::Translateable::VERSION
  s.authors       = ['Joakim Nylén']
  s.email         = ['me@jnylen.nu']
  s.homepage      = 'http://github.com/jnylen/friendly_id-translateable'
  s.summary       = 'Translateable support for FriendlyId.'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test}/*`.split("\n")
  s.require_paths = ['lib']
  s.license       = 'MIT'
  s.description   = 'Adds Translateable support to the FriendlyId gem.'

  s.required_ruby_version = '>= 1.9.3'

  s.add_dependency 'friendly_id', '~> 5.1.0', '< 6.0'
  s.add_dependency 'translateable'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'yard'
end
