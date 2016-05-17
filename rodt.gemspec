# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rodt/version'

Gem::Specification.new do |spec|
  spec.name          = "rodt"
  spec.version       = Rodt::VERSION
  spec.authors       = ["Gregor Schmidt (Planio)"]
  spec.email         = ["schmidt@nach-vorne.eu"]

  spec.summary       = %q{rodt generates ODT documents based on HTML fragments}
  spec.description   = %q{rodt generates ODT documents based on HTML fragments}
  spec.homepage      = "https://plan.io/"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_dependency "mimemagic", "~> 0.3.1"
  spec.add_dependency "nokogiri", "~> 1.6.7.2"
  spec.add_dependency "ruby-xslt", "~> 0.9.9"
  spec.add_dependency "rubyzip", "~> 1.2.0"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "byebug"
end
