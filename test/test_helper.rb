$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'html2odt'

require 'webmock'
require 'minitest/autorun'

require 'pathname'

FIXTURE_PATH = Pathname.new(File.dirname(__FILE__)) + "fixtures"

require 'webmock/minitest'
WebMock.disable_net_connect!
