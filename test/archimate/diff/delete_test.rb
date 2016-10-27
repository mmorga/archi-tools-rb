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
        del = Delete.new(0, model, "Something")
        assert_equal "Something", del.deleted
        assert_equal 0, del.path
      end

      def test_to_s
        diff = Delete.new("Delete", model, "old and busted")
        assert_equal "DELETE: Delete: old and busted", HighLine.uncolor(diff.to_s)
      end

      def test_fmt_to_s
        diff = Delete.new(:model, model, "deleted")
        assert_match "DELETE: ", HighLine.uncolor(diff.to_s)
      end

      def test_diff_description_delete
        diff = Delete.new(:path, model, "deleted")
        assert_match "deleted", diff.to_s
      end

      def test_diagram_id
        diff = Delete.new("Model<abcd1234>/diagrams/1234abcd/children/3439023/source_connection/384793837", model, "old")
        assert_equal "1234abcd", diff.diagram_id, "Expected to find diagram id for #{diff.path}"
      end
    end
  end
end
