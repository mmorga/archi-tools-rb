# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class DeleteTest < Minitest::Test
      def setup
        skip("Diff re-write")
        @model = build_model(with_elements: 1)
        @subject = Delete.new(ArchimateNodeAttributeReference.new(@model, :name))
      end

      def test_to_s
        skip("Diff re-write")
        assert_equal(
          Color.uncolor("DELETE: name from #{@model}"),
          Color.uncolor(@subject.to_s)
        )
      end

      def test_to_s_for_array
        skip("Diff re-write")
        @subject = Delete.new(ArchimateArrayReference.new(@model.elements, 0))

        assert_equal(
          Color.uncolor("DELETE: #{@model.elements.first} from #{@model}/elements"),
          Color.uncolor(@subject.to_s)
        )
      end

      def test_apply
        skip("Diff re-write")
        target = @model.clone

        @subject.apply(target)

        assert_nil target.name
      end

      def test_apply_for_array
        skip("Diff re-write")
        target = @model.clone
        subject = Delete.new(ArchimateArrayReference.new(@model.elements, 0))
        refute_empty target.elements

        subject.apply(target)

        assert_empty target.elements
        refute_empty @model.elements
      end
    end
  end
end
