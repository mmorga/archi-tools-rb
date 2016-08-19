require "archimate/version"
require "archimate/error_helper"
require "archimate/document"
require "archimate/mapper"
require "archimate/merger"
require "archimate/projector"
require "archimate/svger"
require "archimate/duper"
require "archimate/quads"
require "archimate/conversion"
require "archimate/convert"
require "archimate/maybe_io"

module Archimate
  def self.new_xml_doc(xml_str)
    Nokogiri::XML::Document.new(xml_str)
  end
end
