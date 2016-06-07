$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'html2odt'

require 'fakeweb'
require 'minitest/autorun'

require 'pathname'

FIXTURE_PATH = Pathname.new(File.dirname(__FILE__)) + "fixtures"

FakeWeb.allow_net_connect = false
