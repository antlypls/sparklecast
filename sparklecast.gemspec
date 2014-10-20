# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sparklecast/version'

Gem::Specification.new do |spec|
  spec.name          = 'sparklecast'
  spec.version       = Sparklecast::VERSION
  spec.authors       = ['Anatoliy Plastinin']
  spec.email         = ['hello@antlypls.com']
  spec.summary       = "Sparklecast helps you to create and modify Sparkle's " \
                       'appcast files.'
  spec.description   = "Sparklecast helps you to create and modify Sparkle's " \
                       'appcast files.'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = %w(README.md LICENSE)
  spec.files         += Dir.glob('lib/**/*.rb')
  spec.require_paths = ['lib']

  spec.add_dependency 'nokogiri'

  spec.add_development_dependency 'bundler', '~> 1.6'
end
