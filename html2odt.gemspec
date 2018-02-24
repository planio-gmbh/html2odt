# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "html2odt/version"

Gem::Specification.new do |spec|
  spec.name          = "html2odt"
  spec.version       = Html2Odt::VERSION
  spec.authors       = ["Gregor Schmidt (Planio)"]
  spec.email         = ["gregor@plan.io", "support@plan.io"]

  spec.summary       = %q{html2odt generates ODT documents based on HTML fragments}
  spec.description   = %q{html2odt generates ODT documents based on HTML fragments using xhtml2odt}
  spec.homepage      = "https://github.com/planio-gmbh/html2odt"

  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]
  spec.executables   << "html2odt.rb"

  spec.add_dependency "dimensions"
  spec.add_dependency "nokogiri"
  spec.add_dependency "rubyzip"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "webmock"
end
