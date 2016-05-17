require 'test_helper'

class RodtCtorErrorsTest < Minitest::Test
  def test_invalid_template_non_existing_file
    rescued = false
    begin
      Rodt::Odt.new(template: "/invalid/file")
    rescue ArgumentError
      rescued = true
      assert_match(/cannot read template/i, $!.message)
    end
    assert rescued, "Expected ArgumentError"
  end

  def test_invalid_template_no_zip_file
    rescued = false
    begin
      Rodt::Odt.new(template: __FILE__)
    rescue ArgumentError
      rescued = true
      assert_match(/does not look like a ODT file/i, $!.message)
    end
    assert rescued, "Expected ArgumentError"
  end

  def test_invalid_template_no_odt_file
    template = File.join(Dir.tmpdir, "template.odt")

    Zip::File.open(template, Zip::File::CREATE) do |zipfile|
      zipfile.get_output_stream("hello.txt") do |f|
        f.puts "Hello from ZipFile"
      end
    end

    rescued = false
    begin
      Rodt::Odt.new(template: template)
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

    Zip::File.open(template, Zip::File::CREATE) do |zipfile|
      zipfile.get_output_stream("content.xml") do |f|
        f.puts "bla"
      end

      zipfile.get_output_stream("styles.xml") do |f|
        f.puts "blub"
      end
    end

    rescued = false
    begin
      Rodt::Odt.new(template: template)
    rescue ArgumentError
      rescued = true
      assert_match(/does not contain.*{{content}}/i, $!.message)
    end
    assert rescued, "Expected ArgumentError"
  ensure
    File.unlink template if File.exist? template
  end
end
