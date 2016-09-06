# frozen_string_literal: true
require "archimate/version"
require "nokogiri"

module Archimate
  # The root path for YARD source libraries
  ROOT = File.expand_path(File.dirname(__FILE__))

  require File.join(Archimate::ROOT, 'archimate', 'autoload')

  # Creates a new generic xml document given an optional string source
  #
  # @param xml_str Optional string of xml to parse as initial document
  def self.new_xml_doc(xml_str = nil)
    Nokogiri::XML::Document.new(xml_str)
  end

  def self.parse_xml(xml_str)
    Nokogiri::XML(xml_str)
  end
end
