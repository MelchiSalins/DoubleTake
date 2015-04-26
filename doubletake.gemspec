# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'doubletake/version'

Gem::Specification.new do |spec|
  spec.name          = "doubletake"
  spec.version       = Doubletake::VERSION
  spec.authors       = ["Melchi Salins"]
  spec.email         = ["melchisalins@gmail.com"]

  spec.summary       = %q{Visual regression testing tool and more }
  spec.homepage      = "http://melchisalins.users.sf.net/"
  spec.license       = "MIT"
  spec.description   = "This is test description"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency "pry", "~> 0.10.1"
  spec.add_runtime_dependency 'rmagick', '>= 2.13.4', '~> 2.13.4'
  spec.add_runtime_dependency 'selenium-webdriver', '>= 2.45.0', '~> 2.45.0'
  spec.add_runtime_dependency 'thor', '~> 0.19.1'
  spec.post_install_message = "Thanks for installing!"
  spec.required_ruby_version = '>= 1.9.3'
  spec.requirements << 'Firefox browser'
end
