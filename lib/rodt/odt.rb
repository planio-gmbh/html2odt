class Rodt::Odt
  CONTENT_REGEX = /<text:p[^>]*>{{content}}<\/text:p>/
  INCH_TO_CM = 2.54

  # The following value was determined by comparing the generated result with
  # an image dropped into LibreOffice interactively. Though this might be
  # related to the fact, that my screen has a native resolution of 114 dpi.
  #
  # xhtml2odt uses 96 by default.
  DPI = 114.0

  attr_accessor :image_handler

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

      html = prepare_html

      xml = xslt_tranform(html, Rodt::XHTML2ODT_XSL)

      xml = xml.sub('<?xml version="1.0" encoding="utf-8"?>', '')
      xml = @tpl_content_xml.sub(CONTENT_REGEX, xml)

      xml = xslt_tranform(xml, Rodt::XHTML2ODT_STYLES_XSL)

      xml
    end
  end

  def styles_xml
    @styles_xml ||= xslt_tranform(@tpl_styles_xml, Rodt::XHTML2ODT_STYLES_XSL)
  end

  def manifest_xml
    @manifest_xml ||= begin
      content_xml # trigger HTML parsing

      if @images.nil? or @images.empty?
        @tpl_manifest_xml
      else
        doc = Nokogiri::XML(@tpl_manifest_xml)

        @images.each do |image|
          entry = Nokogiri::XML::Node.new "manifest:file-entry", doc
          entry["manifest:full-path"]  = image.target
          entry["manifest:media-type"] = image.mime_type

          doc.root.add_child entry
        end

        doc.to_xml
      end
    end
  end

  def data
    @data ||= begin
      buffer = Zip::OutputStream.write_buffer do |output_stream|
        # Copy contents from template, while replacing content.xml and
        # styles.xml
        Zip::File.open(@template) do |file|
          file.each do |entry|
            next if entry.directory?

            entry.get_input_stream do |input_stream|
              data = case entry.name
              when "content.xml"
                content_xml
              when "styles.xml"
                styles_xml
              when "META-INF/manifest.xml"
                manifest_xml
              else
                input_stream.sysread
              end

              output_stream.put_next_entry(entry.name)
              output_stream.write data
            end
          end
        end

        # Adding images found in the HTML sources
        (@images || []).each do |image|
          output_stream.put_next_entry(image.target)
          output_stream.write File.read(image.source)
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
      @tpl_content_xml  = zip_file.read("content.xml")
      @tpl_manifest_xml = zip_file.read("META-INF/manifest.xml")
      @tpl_styles_xml   = zip_file.read("styles.xml")
    end

    unless @tpl_content_xml =~ CONTENT_REGEX
      raise ArgumentError, "Template file does not contain `{{content}}` paragraph"
    end

  rescue Zip::Error
    raise ArgumentError, "Template file does not look like a ODT file - #{$!.message}"
  rescue Errno::ENOENT
    raise ArgumentError, "Template file does not contain expected file - #{$!.message}"
  end


  def prepare_html
    html = self.html
    html = fix_images_in_html(html)
    html = create_document(html)
    html
  end


  def create_document(html)
    %Q{<html xmlns="http://www.w3.org/1999/xhtml">#{html}</html>}
  end

  def fix_images_in_html(html)
    doc = Nokogiri::HTML::DocumentFragment.parse(html)

    @images = []
    doc.css("img").each_with_index do |img, index|
      image = Rodt::Image.new(index)

      image.source = file_path_for(img["src"])

      if image.valid?
        update_img_tag(img, image)
        @images << image
      else
        # Replace img with link if alt tag is present
        alt = img["alt"]

        if alt.nil? || alt.empty?
          img.remove
        else
          a = Nokogiri::XML::Node.new("a", doc)
          a["href"] = img["src"]
          a.content = alt

          img.replace(a)
        end
      end
    end

    doc.to_xml
  end

  def file_path_for(src)
    if image_handler
      return image_handler.call(src)
    end

    case src
    when /\Afile:\/\//
      # local file URL
      #
      # TODO: Verify, that this does not pose a security threat, maybe make
      # this optional. In any case, it's useful for testing.

      src[7..-1]

    when /\Ahttps?:\/\//
      # remote image URL
      #
      # TODO: Verify, that this does not pose a security threat, maybe make
      # this optional.

      uri = URI.parse(src)
      file = Tempfile.new("rodt")
      file.binmode

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        resp = http.get(uri.path)

        file.write(resp.body)
        file.flush
        file
      end

      file.path
    else
      # cannot handle image properly, return nil
      nil
    end
  end

  def update_img_tag(img, image)
    img["src"] = image.target

    if img["width"] and img["height"]
      # use values supplied in HTML
      width  = img["width"].to_i
      height = img["height"].to_i
    elsif img["width"]
      # compute height based on width keeping aspect ratio
      width = img["width"].to_i
      height = width * image.width / image.height
    elsif img["height"]
      # compute width based on height keeping aspect ratio
      height = img["height"].to_i
      width = height * image.height / image.width
    else
      width  = image.width
      height = image.height
    end

    img["width"]  = "#{(width  / DPI * INCH_TO_CM).round(2)}cm"
    img["height"] = "#{(height / DPI * INCH_TO_CM).round(2)}cm"
  end


  def xslt_tranform(xml, xsl)
    xslt = XML::XSLT.new

    xslt.xml = xml
    xslt.xsl = xsl

    # raises XML::XSLT::ParsingError if XML or XSL are invalid
    xslt.serve
  end

  def reset
    @content_xml  = nil
    @manifest_xml = nil
    @data         = nil
    @images       = nil
  end
end
