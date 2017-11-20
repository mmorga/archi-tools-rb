# frozen_string_literal: true
require 'test_helper'
require 'test_examples'
require 'ruby-prof'
require 'pp'

module Archimate
  module FileFormats
    class ModelExchangeFileReaderTest < Minitest::Test
      attr_accessor :model

      def setup
        @model = ModelExchangeFileReader.new(archisurance_model_exchange_source).parse
      end

      def test_readers
        result_io = StringIO.new
        ModelExchangeFileWriter21.write(@model, result_io)
        written_model = ModelExchangeFileReader.new(result_io.string).parse
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
        printer.print($stdout, min_percent: 1)
      end

      def test_organizations
        organizations = model.organizations
        assert_equal 6, organizations.size
        assert organizations.all? { |e| e.is_a? DataModel::Organization }
        assert_equal 5, organizations[0].organizations.size
        assert_equal 30, organizations[0].organizations[0].items.size
        assert_equal "id-1544", organizations[0].organizations[0].items.first.id
      end

      def test_model_attributes
        assert_equal "id-11f5304f", model.id
        assert_equal "Archisurance", model.name.to_s
        assert_nil model.version
        assert_equal "An example of a fictional Insurance company.", model.documentation.to_s
        assert_equal 1, model.metadata.schema_infos.size
        si = model.metadata.schema_infos.first
        assert_equal "Dublin Core", si.schema
        assert_equal "1.1", si.schemaversion
        assert_equal 6, si.elements.size
        assert_equal "Archisurance Test Exchange Model", si.elements.first.content
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
        assert_equal 7, model.diagrams[1].nodes.size

        d4056 = model.diagrams[1]
        assert_equal 7, d4056.nodes.size
        assert_equal(
          DataModel::Bounds.new(height: 120.0, width: 710.0, x: 20.0, y: 510.0),
          d4056.nodes.first.bounds
        )
        assert_equal 3, d4056.nodes.first.nodes.size
        assert_equal 28, d4056.connections.size
      end

      def test_archi_metal_read_write
        verify_read_write("ArchiMetal V3.xml")
      end

      def test_archisurance_read_write
        verify_read_write("ArchiSurance V3.xml")
      end

      def test_basic_model_read_write
        verify_read_write("Basic_Model.xml")
      end

      def test_basic_model_metadata_read_write
        verify_read_write("Basic_Model_Metadata.xml")
      end

      def test_basic_model_organization_read_write
        verify_read_write("Basic_Model_Organization.xml")
      end

      def test_basic_model_properties_read_write
        verify_read_write("Basic_Model_Properties.xml")
      end

      def test_model_view_read_write
        verify_read_write("Model_View.xml")
      end

      def verify_read_write(filename)
        test_file = File.join(TEST_EXAMPLES_FOLDER, filename)
        source = File.read(test_file)
        model = ModelExchangeFileReader.new(source).parse
        source = source.gsub(" />", "/>").gsub("\r", "")
        result_io = StringIO.new
        ModelExchangeFileWriter30.write(model, result_io)
        written_output = result_io.string
        assert_equal source, written_output
      end
    end
  end
end
