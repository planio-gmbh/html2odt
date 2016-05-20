require 'test_helper'

class ImageHandlingTest < Minitest::Test
  def target
    @target ||= File.join(Dir.tmpdir, "test.odt")
  end

  def teardown
    File.unlink target if File.exist? target
  end

  def test_generator_contains_gem_version
    odt = Html2Odt::Document.new

    odt.html = <<-HTML
      <h1>Hallo Welt</h1>
    HTML

    odt.write_to target

    Zip::File.open(target) do |zipfile|
      assert zipfile.find_entry("meta.xml")

      meta_xml = Nokogiri::XML(zipfile.read("meta.xml"))

      # Generator
      entries = meta_xml.xpath("office:document-meta/office:meta/meta:generator")
      assert_equal 1, entries.size

      entry = entries.first

      assert_equal "html2odt.rb/#{Html2Odt::VERSION}", entry.content

      # Creation Date
      entries = meta_xml.xpath("office:document-meta/office:meta/meta:creation-date")
      assert_equal 1, entries.size

      entry = entries.first

      assert_includes ((Time.now - 10)..Time.now), Time.parse(entry.content)

      # Last Modified Date
      entries = meta_xml.xpath("office:document-meta/office:meta/dc:date")
      assert_equal 1, entries.size

      entry = entries.first

      assert_includes ((Time.now - 10)..Time.now), Time.parse(entry.content)

      # Editing Duration
      entries = meta_xml.xpath("office:document-meta/office:meta/meta:editing-duration")
      assert_equal 1, entries.size

      entry = entries.first

      assert_equal "P0D", entry.content

      # Editing Cycles
      entries = meta_xml.xpath("office:document-meta/office:meta/meta:editing-cycles")
      assert_equal 1, entries.size

      entry = entries.first

      assert_equal "1", entry.content

      # No author or title
      assert_empty meta_xml.xpath("office:document-meta/office:meta/meta:initial-creator")
      assert_empty meta_xml.xpath("office:document-meta/office:meta/dc:creator")
      assert_empty meta_xml.xpath("office:document-meta/office:meta/dc:title")
    end
  end

  def test_with_author_and_title
    odt = Html2Odt::Document.new

    odt.html = <<-HTML
      <h1>Hallo Welt</h1>
    HTML

    odt.title = "Война и миръ"
    odt.author = "Лев Никола́евич Толсто́й"

    odt.write_to target

    Zip::File.open(target) do |zipfile|
      assert zipfile.find_entry("meta.xml")

      meta_xml = Nokogiri::XML(zipfile.read("meta.xml"))


      # Title
      entries = meta_xml.xpath("office:document-meta/office:meta/dc:title")
      assert_equal 1, entries.size

      entry = entries.first

      assert_equal "Война и миръ", entry.content

      # Author
      entries = meta_xml.xpath("office:document-meta/office:meta/dc:creator")
      assert_equal 1, entries.size

      entry = entries.first

      assert_equal "Лев Никола́евич Толсто́й", entry.content

      entries = meta_xml.xpath("office:document-meta/office:meta/meta:initial-creator")
      assert_equal 1, entries.size

      assert_equal "Лев Никола́евич Толсто́й", entry.content
    end
  end
end
