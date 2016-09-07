# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Model
    class DocumentationListTest < Minitest::Test
      PURPOSE = <<-XML
        <?xml version="1.0" encoding="UTF-8"?>
        <archimate:model xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:archimate="http://www.archimatetool.com/archimate" name="Archisurance" id="11f5304f" version="3.1.1">
          <purpose>
            I have no real purpose
          </purpose>
        </archimate:model>
        XML

      ALT_DOCS = <<-XML
        <?xml version="1.0" encoding="UTF-8"?>
        <archimate:model xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:archimate="http://www.archimatetool.com/archimate" name="Archisurance" id="11f5304f" version="3.1.1">
          <purpose>
            I have a small purpose
          </purpose>
          <purpose>
            I have a different purpose
          </purpose>
        </archimate:model>
      XML

      def test_it_handles_no_results
        doc = Archimate.new_xml_doc
        doc_list = DocumentationList.new(doc.css("documentation"))
        assert_empty doc_list.doc_list
      end

      def test_it_handles_a_result_with_one_document
        doc = Archimate.parse_xml(PURPOSE)
        doc_list = DocumentationList.new(doc.css("purpose"))
        assert_equal 1, doc_list.doc_list.size
        assert_equal "I have no real purpose", doc_list.doc_list.first
      end

      def test_it_handles_a_result_with_two_documents
        doc = Archimate.parse_xml(ALT_DOCS)
        doc_list = DocumentationList.new(doc.css("purpose"))
        assert_equal 2, doc_list.doc_list.size
        assert_equal "I have a small purpose", doc_list.doc_list.first
        assert_equal "I have a different purpose", doc_list.doc_list.last
      end

      def test_eql_method
        doc_list1 = DocumentationList.new(Archimate.parse_xml(PURPOSE).css("purpose"))
        doc_list2 = DocumentationList.new(Archimate.parse_xml(ALT_DOCS).css("purpose"))
        refute_equal doc_list1, doc_list2

        doc_list3 = DocumentationList.new(Archimate.parse_xml(PURPOSE).css("purpose"))
        assert_equal doc_list1, doc_list3
      end

      def test_diff_method
        doc_list1 = DocumentationList.new(Archimate.parse_xml(PURPOSE).css("purpose"))
        doc_list2 = DocumentationList.new(Archimate.parse_xml(ALT_DOCS).css("purpose"))

        changes = doc_list1.diff(doc_list2)
        assert_equal Archimate::Diff::Difference.delete("I have no real purpose"), changes[0]
        assert_equal Archimate::Diff::Difference.insert("I have a small purpose"), changes[1]
        assert_equal Archimate::Diff::Difference.insert("I have a different purpose"), changes[2]
        assert_equal 3, changes.size
      end
    end
  end
end
