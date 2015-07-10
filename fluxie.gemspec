# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fluxie/version'

Gem::Specification.new do |spec|
  spec.name          = "fluxie"
  spec.version       = Fluxie::VERSION.dup
  spec.authors       = ["Hannes Nevalainen"]
  spec.email         = ["hannes.nevalainen@me.com"]
  spec.summary       = 'InfluxDB 0.9.x client'
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/kwando/fluxie"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "hurley", "~> 0.1"

  spec.add_development_dependency "bundler", "~> 1.9.0"
  spec.add_development_dependency "rspec"
end
