# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class DeleteTest < Minitest::Test
      attr_accessor :model

      def setup
        @model = build_model
      end

      def test_delete
        del = Delete.new("Model<#{model.id}>/name", model, "Something")
        assert_equal "Something", del.deleted
        assert_equal "Model<#{model.id}>/name", del.path
      end

      def test_to_s
        diff = Delete.new("Model<#{model.id}>/name", model, "old and busted")
        assert_equal "DELETE: in Model<#{model.id}>[#{model.name}] at /name: old and busted", HighLine.uncolor(diff.to_s)
      end

      def test_fmt_to_s
        diff = Delete.new("Model<#{model.id}>/name", model, "deleted")
        assert_match "DELETE: ", HighLine.uncolor(diff.to_s)
      end

      def test_diff_description_delete
        diff = Delete.new("Model<#{model.id}>/name", model, "deleted")
        assert_match "deleted", diff.to_s
      end

      def test_diagram_idx
        diff = Delete.new("Model<abcd1234>/diagrams/[0]/children/[0]/source_connection/[0]", model, "old")
        assert_equal 0, diff.diagram_idx, "Expected to find diagram idx for #{diff.path}"
      end
    end
  end
end
