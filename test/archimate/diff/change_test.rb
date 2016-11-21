# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class ChangeTest < Minitest::Test
      attr_accessor :from_model
      attr_accessor :to_model

      def setup
        @from_model = build_model
        @to_model = build_model
      end

      def test_change
        d = Change.new("Model<#{from_model.id}>/name", from_model, to_model, "from_val", "to_val")
        assert_equal "Model<#{from_model.id}>/name", d.path
        assert_equal "from_val", d.from
        assert_equal "to_val", d.to
      end

      def test_to_s
        diff = Change.new("Model<#{from_model.id}>/name", from_model, to_model, "old and busted", "new hotness")
        assert_equal "CHANGE: in Model<#{from_model.id}>[#{from_model.name}] at /name old and busted -> new hotness", HighLine.uncolor(diff.to_s)
      end

      def test_fmt_kind
        diff = Change.new("Model<#{from_model.id}>/name", from_model, to_model, "old and busted", "new hotness")
        assert_match "CHANGE: ", HighLine.uncolor(diff.to_s)
      end

      def test_sort
      end
    end
  end
end
