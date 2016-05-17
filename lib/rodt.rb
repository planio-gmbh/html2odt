require "xml/xslt"
require "zip"

require "rodt/odt"
require "rodt/version"

module Rodt
  XHTML2ODT_XSL = File.join(File.dirname(__FILE__), "..", "xsl", "xhtml2odt.xsl")
  XHTML2ODT_STYLES_XSL = File.join(File.dirname(__FILE__), "..", "xsl", "styles.xsl")
  ODT_TEMPLATE  = File.join(File.dirname(__FILE__), "..", "odt", "template.odt")
end
