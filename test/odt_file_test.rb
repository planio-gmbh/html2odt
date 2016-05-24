require 'test_helper'

class OdtFileTest < Minitest::Test
  def test_odt_file_creation
    target = File.join(Dir.tmpdir, "test.odt")

    odt = Html2Odt::Document.new
    odt.html = <<-HTML
      <h1>Hallo Welt</h1>
    HTML

    odt.write_to target

    assert File.exist?(target)


    Zip::File.open(target) do |zipfile|
      content_xml = zipfile.read("content.xml")
      assert content_xml.include?("Hallo Welt")

      assert zipfile.find_entry("styles.xml")

      mimetype = zipfile.find_entry("mimetype")
      assert mimetype, "mimetype should exist"
      assert_equal mimetype, zipfile.entries.first, "mimetype should be first entry"
      assert_equal Zlib::NO_COMPRESSION, mimetype.compression_method, "mimetype should not be compressed"
    end

  ensure
    File.unlink target if File.exist? target
  end
end
