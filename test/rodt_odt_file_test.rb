require 'test_helper'

class RodtTest < Minitest::Test
  def test_odt_file_creation
    target = File.join(Dir.tmpdir, "test.odt")

    odt = Rodt::Odt.new
    odt.html = <<-HTML
      <h1>Hallo Welt</h1>
    HTML

    odt.write_to target

    assert File.exist?(target)


    Zip::File.open(target) do |zipfile|
      content_xml = zipfile.read("content.xml")
      assert content_xml.include?("Hallo Welt")

      assert zipfile.find_entry("styles.xml")
    end

  ensure
    File.unlink target if File.exist? target
  end
end
