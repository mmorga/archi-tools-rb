# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class ArchimateArrayPrimitiveReferenceTest < Minitest::Test
      using DataModel::DiffableArray
      def setup
        @model = build_model(with_relationships: 2, with_diagrams: 2, with_elements: 3, with_folders: 4)
        @target = @model.folders.first.items.first
        refute_nil @target
        @subject = ArchimateArrayPrimitiveReference.new(@model.folders.first.items, @target)
        @other = @model.clone
      end

      def test_eql_eql
        assert_equal Archimate.node_reference(@model.folders.first.items, @target), @subject
      end

      def test_value
        assert_same @target, @subject.value
      end

      def test_parent
        assert_same @model.folders.first.items, @subject.parent
      end

      def test_lookup_in_model
        assert_same @other.folders.first.items.first, @subject.lookup_in_model(@other)
      end
    end
  end
end
