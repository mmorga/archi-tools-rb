# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class RelationshipDiffTest < Minitest::Test
      def test_diffs
        r1 = build_relationship
        r2 = r1.with(name: r1.name + "-changed")
        diffs = Context.new(r1, r2).diffs(RelationshipDiff.new)
        expected = [
          Difference.change("Relationship<#{r1.id}>/name", r1.name, r2.name),
        ]
        assert_equal(expected, diffs)
      end
    end
  end
end
