require 'test_helper'

class RodtXslHandlingTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Rodt::VERSION
  end




  def test_nokogiris_xsl_handling_works
    xml = Nokogiri::XML(<<XML)
<?xml version="1.0" encoding="UTF-8"?>
<test>This is a test file</test>
XML

    xslt = Nokogiri::XSLT(<<XSL)
<?xml version="1.0" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>
</xsl:stylesheet>
XSL

    out = xslt.transform(xml).to_s

    assert_equal <<OUT, out
<?xml version=\"1.0\"?>
This is a test file
OUT
  end




  def test_nokogiri_handles_xhtml2odt_xslts
    xml = Nokogiri::XML(<<HTML)
<html xmlns="http://www.w3.org/1999/xhtml">
  <p>
    <span>First</span> <span>Second</span>
  </p>
</html>
HTML

    xslt = File.open(Rodt::XHTML2ODT_XSL, "rb") do |file|
      Nokogiri::XSLT(file)
    end

    out = xslt.transform(xml).to_s

    assert out.include?("First Second")
  end



  def test_odt_transforms_html_to_odt_xml
    odt = Rodt::Odt.new

    odt.html = <<HTML
<p>
  <span>First</span> <span>Second</span>
</p>
HTML

    assert odt.content_xml.include?("First Second")
  end
end
