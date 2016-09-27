# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class ElementDiffTest < Minitest::Test
      def test_with_id_hash
        el1 = build_element
        el2 = build_element
        el3 = build_element
        el4 = build_element
        el2b = el2.with(label: el2.label + "-changed")

        h1 = Archimate.array_to_id_hash([el1, el2, el3])
        h2 = Archimate.array_to_id_hash([el1, el2b, el4])
        diffs = Context.new(h1, h2).diffs(IdHashDiff.new(ElementDiff))
        expected = [
          Difference.change("#{el2.id}/label", el2.label, el2b.label),
          Difference.delete(el3.id, el3),
          Difference.insert(el4.id, el4)
        ]
        assert_equal(expected, diffs)
      end
    end
  end
end
