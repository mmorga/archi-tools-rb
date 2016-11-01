# frozen_string_literal: true
require 'test_helper'

module Archimate
  class ArchiFileReaderTest < Minitest::Test
    attr_accessor :model

    def setup
      @model = ArchiFileReader.read(File.join(TEST_EXAMPLES_FOLDER, "archisurance.archimate"))
    end

    def test_read_diagrams
      assert_equal 17, model.diagrams.size
      assert model.diagram_element_references.all? { |i| i.is_a?(String) }
      assert_equal 120, model.diagram_element_references.size
    end

    def test_folders
      folders = model.folders
      assert_equal 8, folders.size
      assert folders.values.all? { |e| e.is_a? DataModel::Folder }
      assert_equal 5, folders['8c90fdfa'].folders.size
      assert_equal 30, folders['8c90fdfa'].folders['fa63373b'].items.size
      assert folders['8c90fdfa'].folders['fa63373b'].items.all? { |e| e.is_a? String }
      assert_equal "1544", folders['8c90fdfa'].folders['fa63373b'].items[0]
    end
  end
end
