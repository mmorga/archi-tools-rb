# frozen_string_literal: true
require 'test_helper'
require 'test_examples'
require 'archimate/file_formats/archi_file_reader_ox'

module Archimate
  module FileFormats
    class ArchiFileReaderOxTest < Minitest::Test
      attr_accessor :model

      def setup
        starttime = Time.now
        @model = ArchiFileReaderOx.parse(ARCHISURANCE_SOURCE)
        endtime = Time.now
        assert 0.25 > endtime.to_f - starttime.to_f, "Ox reader took: #{endtime.to_f - starttime.to_f} seconds"
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
