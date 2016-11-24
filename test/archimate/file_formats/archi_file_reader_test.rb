# frozen_string_literal: true
require 'test_helper'

module Archimate
  module FileFormats
    class ArchiFileReaderTest < Minitest::Test
      attr_accessor :model

      def setup
        @model = ARCHISURANCE_MODEL
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
