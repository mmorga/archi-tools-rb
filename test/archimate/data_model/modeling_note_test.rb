# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class ModelingNoteTest < Minitest::Test
      def test_constructor
        note = ModelingNote.new(documentation: PreservedLangString.string("docs"))
        assert_equal "docs", note.documentation.to_s
        assert_nil note.type
      end
    end
  end
end
