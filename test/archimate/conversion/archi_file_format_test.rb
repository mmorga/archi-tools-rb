# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Conversion
    class ArchiFileFormatTest < Minitest::Test
      def test_constants
        assert_kind_of Hash, ArchiFileFormat::ELEMENT_TYPE_TO_PARENT_XPATH
        assert_kind_of Array, ArchiFileFormat::FOLDER_XPATHS
        assert_kind_of Array, ArchiFileFormat::RELATION_XPATHS
        assert_kind_of Array, ArchiFileFormat::DIAGRAM_XPATHS
      end
    end
  end
end
