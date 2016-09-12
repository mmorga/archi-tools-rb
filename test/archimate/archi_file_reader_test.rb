# frozen_string_literal: true
require 'test_helper'

module Archimate
  class ArchiFileReaderTest < Minitest::Test
    def test_read_diagrams
      model = ArchiFileReader.read(File.join(TEST_EXAMPLES_FOLDER, "archisurance.archimate"))
      assert_equal 17, model.diagrams.size
      assert_equal 120, model.diagrams.values.map(&:element_references).flatten.uniq.size
      assert_equal 120, model.diagram_element_references.size
    end
  end
end
