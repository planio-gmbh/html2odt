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

  def test_mimetype_entry_has_no_extra_field
    # The ODF specification requires the mimetype entry to carry no "extra
    # field" in its zip local header. The official ODF validator rejects files
    # that do, and strict consumers (older LibreOffice) fail to open them.
    # rubyzip >= 3.0 otherwise injects a Zip64 extra field into every local
    # header.
    target = File.join(Dir.tmpdir, "test.odt")

    odt = Html2Odt::Document.new
    odt.html = <<-HTML
      <h1>Hallo Welt</h1>
    HTML

    odt.write_to target

    data = File.binread(target)

    # Local file header of the first entry (mimetype) starts at offset 0:
    #   0  signature (PK\x03\x04)
    #   26 file name length (2 bytes, little endian)
    #   28 extra field length (2 bytes, little endian)
    assert_equal "PK\x03\x04".b, data[0, 4], "expected a local file header at offset 0"

    name_length  = data[26, 2].unpack1("v")
    extra_length = data[28, 2].unpack1("v")
    name         = data[30, name_length]

    assert_equal "mimetype", name, "mimetype must be the first entry"
    assert_equal 0, extra_length, "mimetype entry must not carry a zip extra field"

  ensure
    File.unlink target if File.exist? target
  end
end
