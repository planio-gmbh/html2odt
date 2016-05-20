class Html2Odt::Document
  CONTENT_REGEX = /<text:p[^>]*>{{content}}<\/text:p>/
  INCH_TO_CM = 2.54

  # The following value was determined by comparing the generated result with
  # an image dropped into LibreOffice interactively. Though this might be
  # related to the fact, that my screen has a native resolution of 114 dpi.
  #
  # xhtml2odt uses 96 by default.
  DPI = 114.0

  attr_accessor :image_location_mapping

  # Document meta data
  attr_accessor :author, :title

  def initialize(template: Html2Odt::ODT_TEMPLATE, html: nil)
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

      xml = xslt_tranform(html, Html2Odt::XHTML2ODT_XSL)

      xml = xml.sub('<?xml version="1.0" encoding="utf-8"?>', '')
      xml = @tpl_content_xml.sub(CONTENT_REGEX, xml)

      xml = xslt_tranform(xml, Html2Odt::XHTML2ODT_STYLES_XSL)

      xml
    end
  end

  def styles_xml
    @styles_xml ||= xslt_tranform(@tpl_styles_xml, Html2Odt::XHTML2ODT_STYLES_XSL)
  end

  def manifest_xml
    @manifest_xml ||= begin
      content_xml # trigger HTML parsing

      if @images.nil? or @images.empty?
        @tpl_manifest_xml
      else
        doc = Nokogiri::XML(@tpl_manifest_xml)

        @images.each do |image|
          entry = create_node(doc, "manifest:file-entry")
          entry["manifest:full-path"]  = image.target
          entry["manifest:media-type"] = image.mime_type

          doc.root.add_child entry
        end

        doc.to_xml
      end
    end
  end

  def meta_xml
    @meta_xml ||= begin
       doc = Nokogiri::XML(@tpl_meta_xml)

       meta = doc.at_xpath("office:document-meta/office:meta")

       meta.xpath("meta:generator").remove
       meta.add_child create_node(doc, "meta:generator", "html2odt.rb/#{Html2Odt::VERSION}")

       meta.xpath("meta:creation-date").remove
       meta.add_child create_node(doc, "meta:creation-date", Time.now.utc.iso8601)

       meta.xpath("dc:date").remove
       meta.add_child create_node(doc, "dc:date", Time.now.utc.iso8601)

       meta.xpath("meta:editing-duration").remove
       meta.add_child create_node(doc, "meta:editing-duration", "P0D")

       meta.xpath("meta:editing-cycles").remove
       meta.add_child create_node(doc, "meta:editing-cycles", "1")

       meta.xpath("meta:initial-creator").remove
       meta.add_child create_node(doc, "meta:initial-creator", author) if author

       meta.xpath("dc:creator").remove
       meta.add_child create_node(doc, "dc:creator", author) if author

       meta.xpath("dc:title").remove
       meta.add_child create_node(doc, "dc:title", title) if title

       doc.to_xml
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
              when "meta.xml"
                meta_xml
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
      @tpl_meta_xml     = zip_file.read("meta.xml")
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
      image = Html2Odt::Image.new(index)

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
          a = create_node(doc, "a")
          a["href"] = img["src"]
          a.content = alt

          img.replace(a)
        end
      end
    end

    doc.to_xml
  end

  def file_path_for(src)
    if image_location_mapping
      return image_location_mapping.call(src)
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
      file = Tempfile.new("html2odt")
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
    xslt = File.open(xsl) do |file|
      Nokogiri::XSLT(file)
    end

    xml = Nokogiri::XML(xml)

    # raises RuntimeError or Nokogiri::XML::SyntaxError if something goes wrong
    xslt.transform(xml).to_s
  end

  def reset
    @content_xml  = nil
    @manifest_xml = nil
    @data         = nil
    @images       = nil
  end

  def create_node(doc, tagname, content = nil)
    entry = Nokogiri::XML::Node.new tagname, doc
    entry.content = content unless content.nil?
    entry
  end
end
