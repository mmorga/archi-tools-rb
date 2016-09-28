# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    # Ok - here's the plan
    # Produce two sets of Differences on two models
    # What are the use cases I need?
    # Inserts (always good)
    # change on the same path == conflict to be resolved
    # change on diff paths == ok
    # delete: diagram (ok)
    # delete: relationship (ok - if source & target also deleted & not referenced by remaining diagrams)
    # delete: element (ok - if not referenced by remaining diagrams)
    class MergeTest < Minitest::Test

      def copy_with_added_element(model, element)
        elements = model.elements.dup
        elements[element.id] = element
        model.with(elements: elements)
      end

      def test_insert_in_remote
        base = build_model(with_elements: 3)
        local = base.dup
        iel = build_element
        remote = copy_with_added_element(base, iel)
        actual = Merge.new.three_way(base, local, remote)
        assert_equal remote, actual
        refute_equal base, actual
        refute_equal base, remote
        refute_equal local, remote
      end

      def test_insert_in_local
        base = build_model(with_elements: 3)
        remote = base.dup
        iel = build_element
        local = copy_with_added_element(base, iel)
        actual = Merge.new.three_way(base, local, remote)
        assert_equal local, actual
        assert_equal base, remote
        refute_equal base, local
        refute_equal local, remote
      end

      def test_no_changes
        base = build_model(with_elements: 3)
        local = Archimate::DataModel::Model.new(base.to_h)
        remote = Archimate::DataModel::Model.new(base.to_h)

        merged = Merge.new.three_way(base, local, remote)

        assert_equal base, merged
        assert_equal local, merged
        assert_equal remote, merged
      end
    end
  end
end
