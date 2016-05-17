require 'test_helper'

class RodtImageHandlingTest < Minitest::Test
  def target
    @target ||= File.join(Dir.tmpdir, "test.odt")
  end

  def teardown
    File.unlink target if File.exist? target
  end

  def test_template_with_image
    odt = Rodt::Odt.new(template: "test/fixtures/template_with_image.odt")

    odt.html = <<-HTML
      <h1>Hallo Welt</h1>
    HTML

    odt.write_to target

    assert File.exist?(target)

    Zip::File.open(target) do |zipfile|
      assert zipfile.find_entry("content.xml")
      assert zipfile.find_entry("styles.xml")
      assert_equal 1, zipfile.glob("Pictures/*.png").size

      href = zipfile.glob("Pictures/*.png").first.name

      content_xml  = Nokogiri::XML(zipfile.read("content.xml"))
      images = content_xml.xpath("//draw:image")
      assert_equal 1, images.size

      image = images.first

      assert_equal href, image["xlink:href"]
    end
  end

  def test_html_with_image
    odt = Rodt::Odt.new

    odt.html = <<-HTML
      <img src="file://#{Dir.pwd}/test/fixtures/nina.png" />
    HTML

    odt.write_to target

    assert File.exist?(target)

    Zip::File.open(target) do |zipfile|
      assert zipfile.find_entry("content.xml")
      assert zipfile.find_entry("styles.xml")
      assert zipfile.find_entry("Pictures/0.png"), "Image not in zip"

      content_xml  = Nokogiri::XML(zipfile.read("content.xml"))
      images = content_xml.xpath("//draw:image")
      assert_equal 1, images.size

      image = images.first

      assert_equal "Pictures/0.png", image["xlink:href"]
    end
  end
end
