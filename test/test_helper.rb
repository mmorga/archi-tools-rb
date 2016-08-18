$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'archimate'
require 'archidiff'
require 'nokogiri'

require 'minitest/autorun'
require 'minitest/color'

module Archidiff
  def self.new_xml_doc
    Nokogiri::XML::Document.new
  end

  def self.parse_xml(xml_str)
    Nokogiri::XML(xml_str)
  end
end
