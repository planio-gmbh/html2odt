# html2odt

This gem provides a Ruby wrapper around the set of XLST stylesheets published as
[xhtml2odt](https://github.com/abompard/xhtml2odt).

[![Build Status](https://travis-ci.org/planio-gmbh/html2odt.svg?branch=master)](https://travis-ci.org/planio-gmbh/html2odt)

## html2odt vs. xhtml2odt

So, why is this project called `html2odt` while the original library and command
line tools by Aurélien Bompard are called **`x`**`html2odt`?

This project uses [nokogiri](http://www.nokogiri.org) to parse the HTML and
apply the XSLT transformations. Nokogiri implements a forgiving HTML parser and
tries be as forgiving as possible. Furthermore, the basic API expects HTML
fragments, not full documents. We are not expecting the users of this library to
pass in a complete, valid XHTML document. A reasonably good piece of HTML should
be good enough. Therefore we skipped the `X` in the name as well.


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

### Command line Usage


```
Usage: html2odt.rb [options] -i input.html -o output.odt
    -i, --input input.html
    -o, --output output.odt
    -t, --template <template.odt>    The file that should be filled with the input's content.
                                     Defaults to basic template file which is part of this gem.
    -r, --replace <KEYWORD>          A keyword in the template document to replace with the converted text.
                                     Defaults to `{{content}}`.
    -u, --url <URL>                  The remote URL you downloaded the page from.
                                     This is required to include remote images and to resolve links properly.
    -h, --help                       Show this message
```


### Ruby API usage

```ruby
# Create an Html2Odt::Document instance
doc = Html2Odt::Document.new

# Set the input HTML
doc.html <<HTML
<h1>Hello, World!</h1>
<p>It works.</p>
HTML

# Set author and title
doc.author = "Jane Doe"
doc.title = "Example Document"


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




Furthermore, you may specify a `base_uri`, which will most likely be the place,
the original HTML fragment belongs to. The `base_uri` will be used to convert
links to fully qualified URLs, so that they still work when placed in the ODT
document. Furthermore the setting will be used to identify the sources of
image's found within the HTML fragments (see below for some detail).

```ruby
# Provide base_uri
doc = Html2Odt::Document.new
doc.base_uri = "https://www.example.com"
```

You may also pass a `URI` instance directly.

```ruby
# Provide base_uri
doc = Html2Odt::Document.new
doc.base_uri = URI::parse("https://www.example.com")
```

It is expected, that the URI refers to a `http(s)` location.


### Image handling

`html2odt` provides basic image inlining, i.e. images referenced in the HTML
code will be embeded into the ODT file by default. This is true for images
referenced with a full `file://`, `http://`, or `https://` URL. Absolute URLs
(i.e. starting `/`) and relative URLs are only supported if the `base_uri`
option is set. Otherwise `html2odt` has no idea, which server or document they
are relating to.

Images referencing an unsupported resource will be replaced with a link
containing the alt text of the image.

If you are using `html2odt` in a web application context, you will probably want
to provide some special handling for resources residing on your own server. This
should be done for security reasons and to save roundtrips.

`html2odt` provides the following API to map image `src` attributes to local
file locations.

```ruby
# Provide custom mapping for image locations
doc = Html2Odt::Document.new

doc.image_location_mapping = lambda do |src|
  root = "/var/www/mywebsite/public"
  path = File.join(root, src)

  # File.realpath raises Errno::ENOENT, if `path` does not exist in file system.
  valid = File.realpath(path).starts_with?(root) rescue false

  valid ? path : nil
end
```

Registering an `image_location_mapping` callback will deactivate the default
behaviour of including images with `file` and `http` URLs automatically.

**Attention:** Be careful! Without a `image_location_mapping` Proc, `html2odt`
will include any local or remote image into the the resulting ODT. This may
cause all kinds of vulnerabilities and should only be used with well known
inputs. When registering an `image_location_mapping` callback, this default
behaviour is deactivated, but please make sure, that your custom code, does not
introduce [path
traversal]:https://en.wikipedia.org/wiki/Directory\_traversal\_attack
vulnerabilities. Following the above example code should be a good start.


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

