# frozen_string_literal: true
require 'test_helper'
require 'test_examples'

module Archimate
  module FileFormats
    class ArchiFileReaderTest < Minitest::Test
      attr_accessor :model

      def setup
        @model = ArchiFileReader.new(Nokogiri::XML(archisurance_source)).parse
      end

      def xtest_reader_profile
        RubyProf.start
        ArchiFileReader.parse(archisurance_source)
        result = RubyProf.stop
        result.eliminate_methods!(
          [
            /Nokogiri/,
            /Dry/
          ]
        )
        printer = RubyProf::FlatPrinterWithLineNumbers.new(result)
        printer.print(STDOUT, min_percent: 1)
      end

      def test_read_diagrams
        assert_equal 17, model.diagrams.size
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
    end
  end
end
