class Rodt::Odt
  def initialize(template: Rodt::ODT_TEMPLATE, html: nil)
    @html     = html
    @template = template

    read_xmls
  end

  def html=(html)
    reset
    @html = html
  end

  def html
    @html
  end

  def content_xml
    @content_xml ||= begin

      xml = xslt_tranform(<<-XML, Rodt::XHTML2ODT_XSL)
        <html xmlns="http://www.w3.org/1999/xhtml">
          #{html}
        </html>
      XML

      xml = xml.sub('<?xml version="1.0" encoding="utf-8"?>', '')
      xml = @tpl_content_xml.sub(/<text:p[^>]*>{{content}}<\/text:p>/, xml)

      xml = xslt_tranform(xml, Rodt::XHTML2ODT_STYLES_XSL)

      xml
    end
  end

  def styles_xml
    @styles_xml ||= xslt_tranform(@tpl_styles_xml, Rodt::XHTML2ODT_STYLES_XSL)
  end

  def data
    @data ||= begin
      buffer = Zip::OutputStream.write_buffer do |output_stream|
        Zip::File.open(@template) do |file|
          file.each do |entry|
            next if entry.directory?

            entry.get_input_stream do |input_stream|
              data = case entry.name
              when "content.xml"
                content_xml
              when "styles.xml"
                styles_xml
              else
                input_stream.sysread
              end

              output_stream.put_next_entry(entry.name)
              output_stream.write data
            end
          end
        end
      end

      buffer.string
    end
  end

  def write_to(path)
    File.write(path, data)
  end

  protected


  def read_xmls
    unless File.readable?(@template)
      raise ArgumentError, "Cannot read template file #{@template.inspect}"
    end

    Zip::File.open(@template) do |zip_file|
      @tpl_content_xml = zip_file.read("content.xml")
      @tpl_styles_xml  = zip_file.read("styles.xml")
    end

  rescue Zip::Error
    raise ArgumentError, "Template file does not look like a ODT file - #{$!.message}"
  rescue Errno::ENOENT
    raise ArgumentError, "Template file does not contain expected file - #{$!.message}"
  end

  def xslt_tranform(xml, xsl)
    xslt = XML::XSLT.new

    xslt.xml = xml
    xslt.xsl = xsl

    xslt.serve
  end

  def reset
    @content_xml = nil
    @data        = nil
  end
end
