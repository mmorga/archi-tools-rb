# frozen_string_literal: true
require 'test_helper'
require 'test_examples'
require 'ruby-prof'
require 'pp'

module Archimate
  module FileFormats
    class ArchiFileReaderTest < Minitest::Test
      attr_accessor :model

      def setup
        @model = ArchiFileReader.new(archisurance_source).parse
      end

      def test_readers
        result_io = StringIO.new
        ArchiFileWriter.write(@model, result_io)
        written_model = ArchiFileReader.new(result_io.string).parse
        assert_equal model, written_model
      end

      def test_reader_profile
        skip("Profile ArchiFileReader")
        RubyProf.start
        ArchiFileReader.new(archisurance_source).parse
        result = RubyProf.stop
        result.eliminate_methods!(
          [
            # /Nokogiri/,
            # /Array/,
            # /Hash/
            # /String/,
            # /Class/
          ]
        )
        printer = RubyProf::FlatPrinterWithLineNumbers.new(result)
        printer.print(STDOUT, min_percent: 1)
      end

      def test_organizations
        organizations = model.organizations
        assert_equal 8, organizations.size
        assert organizations.all? { |e| e.is_a? DataModel::Organization }
        assert_equal 5, organizations.find { |i| i.id == '8c90fdfa' }.organizations.size
        assert_equal 30, organizations.find { |i| i.id == '8c90fdfa' }.organizations.find { |i| i.id == 'fa63373b' }.items.size
        # assert organizations.find { |i| i.id == '8c90fdfa' }.organizations.find { |i| i.id == 'fa63373b' }.items.all? { |e| e.is_a? Archimate::DataModel::Referenceable }
        assert_equal "1544", organizations.find { |i| i.id == '8c90fdfa' }.organizations.find { |i| i.id == 'fa63373b' }.items[0].id
      end

      def test_model_attributes
        assert_equal "11f5304f", model.id
        assert_equal "Archisurance", model.name.to_s
        assert_nil model.metadata
        assert_equal "3.1.1", model.version
        assert_equal "An example of a fictional Insurance company.", model.documentation.to_s
      end

      def test_elements
        assert_equal 120, model.elements.size
        model.elements.each do |el|
          assert_kind_of DataModel::Element, el
        end
      end

      def test_relationships
        assert_equal 178, model.relationships.size
        model.relationships.each do |el|
          assert_kind_of DataModel::Relationship, el
        end
      end

      def test_read_diagrams
        assert_equal 17, model.diagrams.size
        model.diagrams.each do |el|
          assert_kind_of DataModel::Diagram, el
        end
        assert_equal 12, model.diagrams.first.nodes.size

        d4056 = model.diagrams.select{ |dia| dia.id == "4056" }.first
        assert_equal 7, d4056.nodes.size
        assert_equal(
          DataModel::Bounds.new(height: 120.0, width: 710.0, x: 20.0, y: 510.0),
          d4056.nodes.first.bounds
        )
        assert_equal 3, d4056.nodes.first.nodes.size
        assert_equal 28, d4056.connections.size
      end
    end
  end
end
