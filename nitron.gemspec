# -*- encoding: utf-8 -*-
require File.expand_path('../lib/nitron/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Matt Green"]
  gem.email         = ["mattgreenrocks@gmail.com"]
  gem.description   = "Turbocharged iOS development via RubyMotion"
  gem.summary       = "Turbocharged iOS development via RubyMotion"
  gem.homepage      = "https://github.com/mattgreen/nitron"

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "nitron"
  gem.require_paths = ["lib"]
  gem.version       = Nitron::VERSION

  gem.add_dependency 'motion-cocoapods', '>= 1.0.1'
end
