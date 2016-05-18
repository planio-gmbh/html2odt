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

      # zip contains image file
      assert zipfile.find_entry("Pictures/0.png"), "Image not in zip"

      # content xml contains ref to image
      content_xml  = Nokogiri::XML(zipfile.read("content.xml"))
      images = content_xml.xpath("//draw:image")
      assert_equal 1, images.size

      image = images.first
      assert_equal "Pictures/0.png", image["xlink:href"]

      # manifest contains ref to image
      manifest_xml = Nokogiri::XML(zipfile.read("META-INF/manifest.xml"))

      # <manifest:file-entry manifest:full-path="Thumbnails/thumbnail.png"
      #                      manifest:media-type="image/png"/>
      thumbnail = manifest_xml.at_xpath("//manifest:file-entry[@manifest:full-path='Pictures/0.png']")
      assert thumbnail
      assert_equal "image/png", thumbnail["manifest:media-type"]
    end
  end

  def test_image_automatic_size
    odt = Rodt::Odt.new

    odt.html = <<-HTML
      <img src="file://#{Dir.pwd}/test/fixtures/nina.png" />
    HTML

    odt.write_to target

    assert File.exist?(target)

    Zip::File.open(target) do |zipfile|
      # content xml contains ref to image
      content_xml  = Nokogiri::XML(zipfile.read("content.xml"))

      frames = content_xml.xpath("//draw:frame")
      assert_equal 1, frames.size

      frame = frames.first

      # 300 px / 114 dpi = 2.632 inch; 2.632 inch * 2.54 cm/inch = 6.684
      assert_equal "6.68cm", frame["svg:width"]
      assert_equal "6.68cm", frame["svg:height"]
    end
  end

  def test_image_explicit_width
    odt = Rodt::Odt.new

    odt.html = <<-HTML
      <img src="file://#{Dir.pwd}/test/fixtures/nina.png" width=100 />
    HTML

    odt.write_to target

    assert File.exist?(target)

    Zip::File.open(target) do |zipfile|
      # content xml contains ref to image
      content_xml  = Nokogiri::XML(zipfile.read("content.xml"))

      frames = content_xml.xpath("//draw:frame")
      assert_equal 1, frames.size

      frame = frames.first

      # 100 px / 114 dpi = 0.877 inch; 0.877 inch * 2.54 cm/inch = 2.228
      assert_equal "2.23cm", frame["svg:width"]

      # same as width, since aspect is 1:1
      assert_equal "2.23cm", frame["svg:height"]
    end
  end

  def test_image_explicit_height
    odt = Rodt::Odt.new

    odt.html = <<-HTML
      <img src="file://#{Dir.pwd}/test/fixtures/nina.png" height=200 />
    HTML

    odt.write_to target

    assert File.exist?(target)

    Zip::File.open(target) do |zipfile|
      # content xml contains ref to image
      content_xml  = Nokogiri::XML(zipfile.read("content.xml"))

      frames = content_xml.xpath("//draw:frame")
      assert_equal 1, frames.size

      frame = frames.first

      # 200 px / 114 dpi = 1.754 inch; 1.754 inch * 2.54 cm/inch = 4.456
      assert_equal "4.46cm", frame["svg:height"]

      # same as height, since aspect is 1:1
      assert_equal "4.46cm", frame["svg:width"]
    end
  end

  def test_image_explicit_size
    odt = Rodt::Odt.new

    odt.html = <<-HTML
      <img src="file://#{Dir.pwd}/test/fixtures/nina.png" width=100 height=200 />
    HTML

    odt.write_to target

    assert File.exist?(target)

    Zip::File.open(target) do |zipfile|
      # content xml contains ref to image
      content_xml  = Nokogiri::XML(zipfile.read("content.xml"))

      frames = content_xml.xpath("//draw:frame")
      assert_equal 1, frames.size

      frame = frames.first

      # 100 px / 114 dpi = 0.877 inch; 0.877 inch * 2.54 cm/inch = 2.228
      assert_equal "2.23cm", frame["svg:width"]

      # 200 px / 114 dpi = 1.754 inch; 1.754 inch * 2.54 cm/inch = 4.456
      assert_equal "4.46cm", frame["svg:height"]
    end
  end
end
