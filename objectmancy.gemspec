# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'objectmancy/version'

Gem::Specification.new do |spec|
  spec.name          = 'objectmancy'
  spec.version       = Objectmancy::VERSION
  spec.authors       = ['Jon Anderson']
  spec.email         = ['jon1992@gmail.com']

  spec.summary       = 'Set of extensions used to convert a hash to an object.'
  spec.description   = 'Set of extensions used to convert a hash to an object.'
  spec.homepage      = 'http://github.com'
  spec.license       = 'MIT'

  spec.files         = ['lib/**/*']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rubocop', '0.43'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
end
