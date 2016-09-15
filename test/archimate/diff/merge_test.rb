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
      # insertion in one model
      def test_insert_in_remote
        base = build_model(with_elements: 3)
        local = base.dup
        remote = base.dup
        iel = build_element
        remote.add_element(iel)
        merge = Merge.new
        actual = merge.three_way(base, local, remote)
        assert_equal remote, actual
      end

      def test_insert_in_local
        base = build_model(with_elements: 3)
        local = base.dup
        remote = base.dup
        iel = build_element
        local.add_element(iel)
        merge = Merge.new
        actual = merge.three_way(base, local, remote)
        assert_equal local, actual
        refute_equal local, remote
      end
    end
  end
end
