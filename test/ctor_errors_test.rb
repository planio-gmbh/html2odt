require 'test_helper'

class CtorErrorsTest < Minitest::Test
  def test_invalid_template_non_existing_file
    rescued = false
    begin
      Html2Odt::Document.new(template: "/invalid/file")
    rescue ArgumentError
      rescued = true
      assert_match(/cannot read template/i, $!.message)
    end
    assert rescued, "Expected ArgumentError"
  end

  def test_invalid_template_no_zip_file
    rescued = false
    begin
      Html2Odt::Document.new(template: __FILE__)
    rescue ArgumentError
      rescued = true
      assert_match(/does not look like an ODT file/i, $!.message)
    end
    assert rescued, "Expected ArgumentError"
  end

  def test_invalid_template_no_odt_file
    template = File.join(Dir.tmpdir, "template.odt")

    Zip::OutputStream.open(template) do |zos|
      zos.put_next_entry("hello.txt")
      zos.write "Hello from ZipFile\n"
    end

    rescued = false
    begin
      Html2Odt::Document.new(template: template)
    rescue ArgumentError
      rescued = true
      assert_match(/does not contain expected file/i, $!.message)
    end
    assert rescued, "Expected ArgumentError"
  ensure
    File.unlink template if File.exist? template
  end

  def test_invalid_template_no_content_paragraph
    template = File.join(Dir.tmpdir, "template.odt")

    Zip::OutputStream.open(template) do |zos|
      zos.put_next_entry("content.xml")
      zos.write "bla\n"

      zos.put_next_entry("styles.xml")
      zos.write "blub\n"

      zos.put_next_entry("META-INF/manifest.xml")
      zos.write "blub\n"

      zos.put_next_entry("meta.xml")
      zos.write "blub\n"
    end

    rescued = false
    begin
      Html2Odt::Document.new(template: template)
    rescue ArgumentError
      rescued = true
      assert_match(/does not contain.*{{content}}/i, $!.message)
    end
    assert rescued, "Expected ArgumentError"
  ensure
    File.unlink template if File.exist? template
  end
end
