require 'test_helper'

class RodtXslHandlingTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Rodt::VERSION
  end




  def test_ruby_xslt_works
    xslt = XML::XSLT.new

    xslt.xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<test>This is a test file</test>
XML

    xslt.xsl = <<XSL
<?xml version="1.0" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>
</xsl:stylesheet>
XSL

    out = xslt.serve

    assert_equal <<OUT, out
<?xml version=\"1.0\"?>
This is a test file
OUT
  end




  def test_ruby_xslt_handles_xhtml2odt_xslts
    xslt = XML::XSLT.new

    xslt.xml = <<HTML
<html xmlns="http://www.w3.org/1999/xhtml">
  <p>
    <span>First</span> <span>Second</span>
  </p>
</html>
HTML

    xslt.xsl = Rodt::XHTML2ODT_XSL

    out = xslt.serve

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
