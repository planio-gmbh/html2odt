require 'test_helper'

class LinkHandlingTest < Minitest::Test
  def test_full_qualified_urls
    odt = Html2Odt::Document.new

    odt.html = "<p><a href=\"http://www.example.org/baz\">Link</a></p>"
    odt.base_uri = "https://www.example.com/foo/bar"

    content_xml = Nokogiri::XML(odt.content_xml)

    as = content_xml.css("text|a")
    assert_equal 1, as.size

    a = as.first

    assert_equal "http://www.example.org/baz", a["xlink:href"]
  end

  def test_relative_links
    odt = Html2Odt::Document.new

    odt.html = "<p><a href=\"baz\">Link</a></p>"
    odt.base_uri = "https://www.example.com/foo/bar"

    content_xml = Nokogiri::XML(odt.content_xml)

    as = content_xml.css("text|a")
    assert_equal 1, as.size

    a = as.first

    assert_equal "https://www.example.com/foo/baz", a["xlink:href"]
  end

  def test_absolute_links
    odt = Html2Odt::Document.new

    odt.html = "<p><a href=\"/baz\">Link</a></p>"
    odt.base_uri = "https://www.example.com/foo/bar"

    content_xml = Nokogiri::XML(odt.content_xml)

    as = content_xml.css("text|a")
    assert_equal 1, as.size

    a = as.first

    assert_equal "https://www.example.com/baz", a["xlink:href"]
  end

  def test_links_wo_protocol
    odt = Html2Odt::Document.new

    odt.html = "<p><a href=\"//www.example.org/\">Link</a></p>"
    odt.base_uri = "https://www.example.com/foo/bar"

    content_xml = Nokogiri::XML(odt.content_xml)

    as = content_xml.css("text|a")
    assert_equal 1, as.size

    a = as.first

    assert_equal "https://www.example.org/", a["xlink:href"]
  end

  def test_invalid_links
    odt = Html2Odt::Document.new

    odt.html = "<p><a href=\"http://proxy.domain.tld:port\">Link</a></p>"
    odt.base_uri = "https://www.example.com/foo/bar"

    content_xml = Nokogiri::XML(odt.content_xml)

    as = content_xml.css("text|a")
    assert_equal 1, as.size

    a = as.first

    assert_equal "http://proxy.domain.tld:port", a["xlink:href"]
  end
end
