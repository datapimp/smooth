# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'smooth/version'

Gem::Specification.new do |spec|
  spec.name          = "smooth"
  spec.version       = Smooth::VERSION
  spec.authors       = ["Jonathan Soeder"]
  spec.email         = ["jonathan.soeder@gmail.com"]
  spec.description   = %q{Smooth provides a simple DSL building powerful JSON APIs on top of ActiveRecord.}
  spec.summary       = %q{Smooth provides a DSL for creating self-testing, self-documenting, highly inspectable API endpoints which are able to generate extendable client libraries.}
  spec.homepage      = "http://smooth.io"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
    
  spec.add_dependency 'hashie'
  spec.add_dependency 'activesupport', '>= 4.0.0'
  spec.add_dependency 'activerecord', '>= 4.0.0'
  spec.add_dependency 'active_model_serializers', '~> 0.8.0'
  spec.add_dependency 'faker'
  spec.add_dependency 'mutations'
  spec.add_dependency 'sinatra'
  spec.add_dependency 'escape_utils'
  spec.add_dependency 'uri_template'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-nav"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency 'rails'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'sqlite3'
end
