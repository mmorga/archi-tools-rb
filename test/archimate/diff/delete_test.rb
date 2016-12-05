# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class DeleteTest < Minitest::Test
      def setup
        @model = build_model(with_elements: 1)
        @subject = Delete.new(Archimate.node_reference(@model, "name"))
      end

      def test_to_s
        assert_equal(
          HighLine.uncolor("DELETE: name from #{@model}"),
          HighLine.uncolor(@subject.to_s)
        )
      end

      def test_to_s_for_array
        @subject = Delete.new(Archimate.node_reference(@model.elements.first))

        assert_equal(
          HighLine.uncolor("DELETE: #{@model.elements.first} from #{@model}/elements"),
          HighLine.uncolor(@subject.to_s)
        )
      end

      def test_apply
        target = @model.clone

        @subject.apply(target)

        assert_nil target.name
      end

      def test_apply_for_array
        target = @model.clone
        deleted_element = @model.elements.first
        subject = Delete.new(Archimate.node_reference(deleted_element))
        refute_empty target.elements

        subject.apply(target)

        assert_empty target.elements
        refute_empty @model.elements
      end
    end
  end
end
