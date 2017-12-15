# v0.4.3 - 2017-12-15

Handle files smaller than 6144 bytes. Relaxed version requirements.

# v0.4.2 - 2017-12-15

Try harder to determine image dimensions.

# v0.4.1 - 2017-09-19

Add support for nokogiri 1.8 in adition to the currently supported versions

# v0.4.0 - 2017-03-30

Bump required nokogiri version

# v0.3.3 - 2016-06-07

Properly handle HTTP errors on remote image handling. Improved handling of top
level inline elements.

# v0.3.2 - 2016-06-07

Properly handle errors on remote image handling, bump nokogiri dependency to
address security related bugs

# v0.3.1 - 2016-06-06

Improved support for Ruby 2.0.0, improved handling of invalid URIs

# v0.3.0 - 2016-05-25

Adding support for `base_uri` configuration to expand links and download images
without fully qualified URI.

Adding html2odt.rb binary.

# v0.2.1 - 2016-05-25

Adding workarounds for HTML structures not supported by xhtml2odt.

# v0.2.0 - 2016-05-24

Generating OpenDocument v1.1 instead of 1.2 to improve compatibility with
Microsoft Office 2010. Improving compatibility with OpenDocument standard.

# v0.1.1 - 2016-05-23

Being less strict about rubyzip version.

# v0.1.0 - 2016-05-20 - Initial release

Provides initial feature set, tranforming HTML fragments to ODT documents.
