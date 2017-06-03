# frozen_string_literal: true
require 'test_helper'
require 'test_examples'

module Archimate
  module FileFormats
    class ArchiFileReaderTest < Minitest::Test
      attr_accessor :model

      def setup
        @model = ArchiFileReader.parse(ARCHISURANCE_SOURCE)
      end

      def xtest_reader_profile
        RubyProf.start
        ArchiFileReader.parse(ARCHISURANCE_SOURCE)
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

      def test_folders
        folders = model.folders
        assert_equal 8, folders.size
        assert folders.all? { |e| e.is_a? DataModel::Folder }
        assert_equal 5, folders.find { |i| i.id == '8c90fdfa' }.folders.size
        assert_equal 30, folders.find { |i| i.id == '8c90fdfa' }.folders.find { |i| i.id == 'fa63373b' }.items.size
        assert folders.find { |i| i.id == '8c90fdfa' }.folders.find { |i| i.id == 'fa63373b' }.items.all? { |e| e.is_a? String }
        assert_equal "1544", folders.find { |i| i.id == '8c90fdfa' }.folders.find { |i| i.id == 'fa63373b' }.items[0]
      end
    end
  end
end
