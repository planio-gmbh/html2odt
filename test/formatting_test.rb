require 'test_helper'

class FormattingTest < Minitest::Test
  def test_pre_elements
    odt = Html2Odt::Document.new
    odt.html = <<HTML
<pre>
abc
  def
ghi
</pre>
HTML

    content_xml = Nokogiri::XML(odt.content_xml)

    pres = content_xml.css("text|p[text|style-name=Preformatted_20_Text]")
    assert_equal 1, pres.size

    assert_equal '<text:p text:style-name="Preformatted_20_Text">' +
                    '<text:line-break/>' +
                    'abc<text:line-break/>' +
                    '<text:s text:c="2"/>def<text:line-break/>' +
                    'ghi' +
                 '</text:p>',
                 pres.first.to_xml
  end

  def test_inline_code_elements
    odt = Html2Odt::Document.new
    odt.html = "<p>abc <code>def</code> ghi</p>"

    content_xml = Nokogiri::XML(odt.content_xml)

    ps = content_xml.css("text|p[text|style-name=Text_20_body]")
    assert_equal 1, ps.size

    p = ps.first

    assert_equal "<text:p text:style-name=\"Text_20_body\">" +
                    "abc " +
                    "<text:span text:style-name=\"Teletype\">def</text:span>" +
                    " ghi" +
                 "</text:p>",
                 p.to_xml
  end

  def test_block_code_elements
    odt = Html2Odt::Document.new
    odt.html = "<p>abc</p><code>def</code><p>ghi</p>"

    content_xml = Nokogiri::XML(odt.content_xml)

    ps = content_xml.css("text|p[text|style-name=Text_20_body]")
    assert_equal 3, ps.size

    assert_equal "<text:p text:style-name=\"Text_20_body\">abc</text:p>", ps.shift.to_xml
    assert_equal "<text:p text:style-name=\"Text_20_body\">\n" +
                 "  <text:span text:style-name=\"Teletype\">def</text:span>\n" +
                 "</text:p>", ps.shift.to_xml
    assert_equal "<text:p text:style-name=\"Text_20_body\">ghi</text:p>", ps.shift.to_xml
  end

  def test_nested_br_within_pres
    odt = Html2Odt::Document.new
    odt.html = "<pre>def foo<br/>  \"foo\"<br/>end</pre>"

    content_xml = Nokogiri::XML(odt.content_xml)

    ps = content_xml.css("text|p[text|style-name=Preformatted_20_Text]")
    assert_equal 1, ps.size

    children = ps.first.children

    assert_equal "def foo",                children.shift.to_xml
    assert_equal "<text:line-break/>",     children.shift.to_xml
    assert_equal "<text:s text:c=\"2\"/>", children.shift.to_xml
    assert_equal "\"foo\"",                children.shift.to_xml
    assert_equal "<text:line-break/>",     children.shift.to_xml
    assert_equal "end",                    children.shift.to_xml
  end

  def test_code_within_pres
    odt = Html2Odt::Document.new
    odt.html = "<pre><code>def foo<br />  \"foo\"<br />end</code></pre>"

    content_xml = Nokogiri::XML(odt.content_xml)

    codes = content_xml.css("text|p[text|style-name=Preformatted_20_Text] text|span[text|style-name=Teletype]")
    assert_equal 1, codes.size

    children = codes.first.children

    assert_equal "def foo",                children.shift.to_xml
    assert_equal "<text:line-break/>",     children.shift.to_xml
    assert_equal "<text:s text:c=\"2\"/>", children.shift.to_xml
    assert_equal "\"foo\"",                children.shift.to_xml
    assert_equal "<text:line-break/>",     children.shift.to_xml
    assert_equal "end",                    children.shift.to_xml
  end

  def test_with_insignificant_white_space
    odt = Html2Odt::Document.new
    odt.html = "<p>first paragraph</p> \n\t<p>second paragraph</p>"

    content_xml = Nokogiri::XML(odt.content_xml)

    paragraphs = content_xml.css("text|p[text|style-name=Text_20_body]")
    assert_equal 2, paragraphs.size


    assert_equal "<text:p text:style-name=\"Text_20_body\">" +
                    "first paragraph" +
                 "</text:p>",
                 paragraphs.first.to_xml
    assert_equal "<text:p text:style-name=\"Text_20_body\">" +
                    "second paragraph" +
                 "</text:p>",
                 paragraphs.last.to_xml
  end

  def test_inline_element_without_containing_block_element
    odt = Html2Odt::Document.new
    odt.html = "<p>first</p> <strong>strong</strong> <em>em</em> text <p>last</p>"

    content_xml = Nokogiri::XML(odt.content_xml)

    paragraphs = content_xml.css("text|p[text|style-name=Text_20_body]")
    assert_equal 3, paragraphs.size


    assert_equal "<text:p text:style-name=\"Text_20_body\">first</text:p>",
                 paragraphs.first.to_xml
    assert_equal "<text:p text:style-name=\"Text_20_body\">last</text:p>",
                 paragraphs.last.to_xml

    assert_equal "<text:p text:style-name=\"Text_20_body\">" +
                   "<text:span text:style-name=\"strong\">strong</text:span> " +
                   "<text:span text:style-name=\"emphasis\">em</text:span> " +
                   "text " +
                 "</text:p>",
                 paragraphs[1].to_xml
  end
end
