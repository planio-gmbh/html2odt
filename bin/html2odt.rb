#!/usr/bin/env ruby

require 'optparse'
require 'html2odt'

options = {}
parser = OptionParser.new do |opts|
  opts.banner = "Usage: html2odt.rb [options] -i input.html -o output.odt"

  opts.on("-i", "--input input.html") do |input|
    options[:input] = input
  end

  opts.on("-o", "--output output.odt") do |output|
    options[:output] = output
  end

  opts.on("-t", "--template <template.odt>",
          "The file that should be filled with the input's content.", "Defaults to basic template file which is part of this gem.") do |template|
    options[:template] = template
  end

  opts.on("-r", "--replace <KEYWORD>",
          "A keyword in the template document to replace with the converted text.", "Defaults to `{{content}}`.") do |replace|
    options[:replace] = replace
  end

  opts.on("-u", "--url <URL>",
          "The remote URL you downloaded the page from.", "This is required to include remote images and to resolve links properly.") do |url|
    options[:url] = url
  end

  opts.on("-h", "--help",
          "Show this message") do
    puts opts
    exit
  end
end

parser.parse!

if options.empty?
  puts parser
  exit
end

if options[:replace]
  warn "-r option is not yet implemented, please use the default `{{content}}` place holder for now."
  exit 1
end


if options[:input].nil?
  warn "Missing -i option"
  puts parser
  exit 1
end


if options[:output].nil?
  warn "Missing -o option"
  puts parser
  exit 1
end



doc = if options[:template].nil?
  Html2Odt::Document.new
else
  begin
    Html2Odt::Document.new(template: options[:template])
  rescue ArgumentError
    warn "Template does not match expectations - #{$!.message}"
    exit 2
  end
end


if File.readable? options[:input]
  doc.html = File.read(options[:input])
else
  warn "Input does not match expectations - Cannot read input file #{options[:input].inspect}"
  exit 3
end


if options[:url]
  begin
    doc.base_uri = options[:url]
  rescue ArgumentError
    warn "URL does not match expectations - #{$!.message}"
    exit 4
  end
end


doc.write_to options[:output]

puts "Wrote document to: #{options[:output]}"
