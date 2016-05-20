require "net/http"
require "tempfile"
require "time"
require "uri"

require "dimensions"
require "nokogiri"
require "zip"

module Html2Odt
  XHTML2ODT_XSL = File.join(File.dirname(__FILE__), "..", "xsl", "xhtml2odt.xsl")
  XHTML2ODT_STYLES_XSL = File.join(File.dirname(__FILE__), "..", "xsl", "styles.xsl")
  ODT_TEMPLATE  = File.join(File.dirname(__FILE__), "..", "odt", "template.odt")
end

require "html2odt/document"
require "html2odt/image"
require "html2odt/version"
