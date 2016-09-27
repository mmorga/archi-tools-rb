# frozen_string_literal: true
require 'test_helper'

class ArchimateTest < Minitest::Test
  def test_new_xml_doc_with_nil
    doc = Archimate.new_xml_doc
    assert_kind_of Nokogiri::XML::Document, doc
    assert_nil doc.root
  end
end
