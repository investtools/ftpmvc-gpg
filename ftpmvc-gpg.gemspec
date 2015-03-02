# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ftpmvc/gpg/version'

Gem::Specification.new do |spec|
  spec.name          = "ftpmvc-gpg"
  spec.version       = FTPMVC::GPG::VERSION
  spec.authors       = ["André Aizim Kelmanson"]
  spec.email         = ["akelmanson@gmail.com"]
  spec.summary       = "FTPMVC filter to encrypt/decrypt files"
  spec.description   = "FTPMVC filter to encrypt/decrypt files"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "guard-rspec"
  spec.add_dependency "ftpmvc", '>= 0.9.0'
  spec.add_dependency "gpgme"
end
