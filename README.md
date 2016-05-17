# Rodt


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rodt'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rodt

## Usage

### Basic usage

```ruby
# Create an Odt instance
odt = Rodt::Odt.new

# Set the input HTML
odt.html <<HTML

<h1>Hello, World!</h1>

<p>It works.</p>

HTML

# Write ODT to disk
odt.write_to "demo.odt"

# Or get binary content as string
odt.data
```

### Ctor options

`rodt` comes with a basic `template.odt`, which is as a boilerplate to create
the desired ODT file. If you like to provide your own styles or additional
content next to the content added via the API, you may provide your own template
in the `Rodt::Odt` constructor.

*Please note:* If the template file cannot be read or if it does not appear to
be a valid ODT file, an `ArgumentError` will be raised.

The template needs to contain an otherwise empty paragraph containing the string
`{{content}}`.

```ruby
# Provide optional template file
odt = Rodt::Odt.new(template: "template.odt")
```




The HTML which should become part of the document may also be provided via the
constructor

```ruby
# Provide HTML in constructor
odt = Rodt::Odt.new(html: <<HTML)
  <h1>Hello, World!</h1>
  <p>It works.</p>
HTML
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
https://github.com/schmidt/rodt. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

