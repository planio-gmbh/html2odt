# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'html2odt/version'

Gem::Specification.new do |spec|
  spec.name          = "html2odt"
  spec.version       = Html2Odt::VERSION
  spec.authors       = ["Gregor Schmidt (Planio)"]
  spec.email         = ["gregor@plan.io", "support@plan.io"]

  spec.summary       = %q{html2odt generates ODT documents based on HTML fragments}
  spec.description   = %q{html2odt generates ODT documents based on HTML fragments using xhtml2odt}
  spec.homepage      = "https://github.com/planio-gmbh/html2odt"

  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_dependency "dimensions", "~> 1.3.0"
  spec.add_dependency "nokogiri", "~> 1.6.7.2"
  spec.add_dependency "rubyzip", "~> 1.2.0"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "byebug"
end
