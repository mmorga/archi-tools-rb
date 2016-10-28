# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class InsertTest < Minitest::Test
      attr_accessor :model

      def setup
        @model = build_model
      end

      def test_insert
        d = Insert.new("Model<#{model.id}>/name", model, "to_val")
        assert_equal "Model<#{model.id}>/name", d.path
        assert_equal "to_val", d.inserted
      end

      def test_to_s
        diff = Insert.new("Model<#{model.id}>/name", model, "to_val")
        assert_match "INSERT: ", HighLine.uncolor(diff.to_s)
      end

      def test_diff_description_insert
        diff = Insert.new("Model<#{model.id}>/name", model, "to_val")
        assert_match "to_val", diff.to_s
      end
    end
  end
end
