# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'archimate/version'

Gem::Specification.new do |spec|
  spec.name          = "archimate"
  spec.version       = Archimate::VERSION
  spec.authors       = ["Mark Morga"]
  spec.email         = ["mmorga@rackspace.com"]

  spec.summary       = "Archi Tools"
  spec.description   = "A collection of tools for working with ArchiMate files from Archi"
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "nokogiri", "~> 1.6"
  spec.add_runtime_dependency "colorize", "~> 0.7"
  spec.add_runtime_dependency "rmagick", "~> 2.15"
  spec.add_runtime_dependency "thor", "~> 0.19"
  spec.add_runtime_dependency "highline", "~> 1.7"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "guard", "~> 2.13"
  spec.add_development_dependency "guard-minitest", "~> 2.4"
end
