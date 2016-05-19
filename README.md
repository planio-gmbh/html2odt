# html2odt

This gem provides a Ruby wrapper around the set of XLST stylesheets published as
[xhtml2odt](https://github.com/abompard/xhtml2odt).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'html2odt'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install html2odt

## Usage

### Basic usage

```ruby
# Create an Html2Odt::Document instance
doc = Html2Odt::Document.new

# Set the input HTML
doc.html <<HTML

<h1>Hello, World!</h1>

<p>It works.</p>

HTML

# Write ODT to disk
doc.write_to "demo.odt"

# Or get binary content as string
doc.data
```

### Configuration options

`html2odt` comes with a basic `template.odt`, which is as a boilerplate to create
the desired ODT file. If you like to provide your own styles or additional
content next to the content added via the API, you may provide your own template
in the `Html2Odt::Document` constructor.

*Please note:* If the template file cannot be read or if it does not appear to
be a valid ODT file, an `ArgumentError` will be raised.

The template needs to contain an otherwise empty paragraph containing the string
`{{content}}`.

```ruby
# Provide optional template file
doc = Html2Odt::Document.new(template: "template.odt")
```




The HTML which should become part of the document may also be provided via the
constructor

```ruby
# Provide HTML in constructor
doc = Html2Odt::Document.new(html: <<HTML)
  <h1>Hello, World!</h1>
  <p>It works.</p>
HTML
```

### Image handling

`html2odt` provides basic image inlining, i.e. images referenced in the HTML
code will be embeded into the ODT file by default. This is true for images
referenced with a full `file://`, `http://`, or `https://` URL. Absolute URLs
(i.e. starting `/`) and relative URLs are not supported, since `html2odt` has no
idea, which server or document they are relating to.

Images referencing an unsupported resource will be replaced with a link
containing the alt text of the image.

If you are using `html2odt` in a web application context, you will probably want
to provide some special handling for resources residing on your own server. This
should be done for security reasons or to save roundtrips.

`html2odt` provides the following API to map image `src` attributes to local
file locations.

```ruby
# Provide custom mapping for image locations
doc = Html2Odt::Document.new

doc.image_location_mapping = lambda do |src|
  # Attention! Add protection against directory traversal attacks
  "/var/www/mywebsite/#{src}"
end
```

Registering an `image_location_mapping` callback will deactivate the default
behaviour of including images with `file` and `http` URLs automatically.


## License

Files within the `xsl` directory belong to the [xhtml2odt
project](https://github.com/abompard/xhtml2odt) published by Aurelien Bompard
(2009-2010) under the terms of the GNU LGP v2.1 or later:
http://www.gnu.org/licenses/lgpl-2.1.html

The remaining files are licensed under the terms of the MIT license.

```
Copyright (c) 2016 Gregor Schmidt - Planio GmbH, Berlin, Germany

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```



## Development

After checking out the repo, run `bundle install` to install dependencies. Then,
run `rake test` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/planio-gmbh/html2odt. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

